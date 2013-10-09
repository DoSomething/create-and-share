class PostsController < ApplicationController
  include Services

  # Get campaign
  before_filter :get_campaign, except: [:get_posts, :expire_pages, :autoimg, :edit, :update, :destroy, :flag, :thumbs]
  before_filter :get_user, only: [:index, :show, :filter, :vanity, :extras]

  # Before everything runs, run an authentication check and an API key check.
  before_filter :is_not_authenticated, :verify_api_key, :campaign_closed
  skip_before_filter :campaign_closed, only: [:create, :update]

  before_filter only: [:edit, :destroy, :flag] do
    raise 'User ' + (session[:drupal_user_id] || 0).to_s + ' is unauthorized.' unless admin?
  end

  before_filter :build_stats, only: [:index, :scroll, :page], unless: lambda { params[:filter] && !params[:filter].empty? && params[:filter] != "index" }
  # Ignores xsrf in favor of API keys for JSON requests.
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' || ['thumbs', 'share', 'flag'].include?(params[:action]) }

  caches_action :index

  # Shows the static (closed) gallery when a campaign is finished, or not started yet.
  def campaign_closed
    now = Time.now
    if @campaign && (@campaign.start_date > now || @campaign.end_date < now)
      render 'static_pages/gallery'
      return
    end
  end

  def build_stats
    if @campaign.stat_frequency == 0
      return []
    end

    stats = Rails.application.config.stats[@campaign.path]
    page = params[:page].to_i || 0
    seen = params[:seen] || []
    sc = stats.clone

    @shown_stats = []

    # Page 1
    if page == 0
      @shown_stats << sc.shift
      @shown_stats << sc.sample(Post.per_page/@campaign.stat_frequency)
    # Page 2, 4, 6 ,etc
    elsif page % 2 == 1
      @shown_stats = sc - seen
    # Page 3, 5, 7, etc
    elsif page % 2 == 0
      @shown_stats = sc.sample(Post.per_page/@campaign.stat_frequency)
    end

    @shown_stats.flatten!
  end

  def get_posts(offset, count, filter = 'index')
    last_post = Post.where(campaign_id: @campaign.id, flagged: false)
    unless last_post.nil? || last_post.empty?
      last_post = last_post.last.created_at.to_i.to_s
      posts = Rails.cache.fetch filter + '-first-posts' do
        Post.where(flagged: false).last(200).reverse.map(&:id)
      end

      cached = Rails.cache.fetch filter + '-offset-' + offset.to_s + '-' + count.to_s + '/' + last_post do
        posts = posts.slice(offset, count)
        unless posts.nil?
          get = {}
          posts.each_with_index do |post, index|
            p = Rails.cache.read 'post-' + post.to_s
            if p.nil?
              get[index] = post
            else
              posts[index] = p
            end
          end

          unless get.empty?
            results = Post.where(id: get.values).inject({}) do |res, post|
              res[post.id] = post
              res
            end

            get.each do |index_pos, value|
              if results[value]
                Rails.cache.write 'post-' + value.to_s, results[value]
                posts[index_pos] = results[value]
              end
            end
          end

          posts
        else
          posts = []
        end

        posts
      end
    else
      cached = []
    end

    cached
  end

  # GET /posts
  # GET /posts.json
  def index
    unless params[:page] && params[:page].to_i > 1
      @posts = Rails.cache.fetch 'index-posts' do
        get_posts(0, Post.per_page)
      end
    end

    @filter = 'index'
    @admin = (admin? ? 'admin' : 'member')

    respond_to do |format|
      format.html
      format.json { render json: @posts, root: false }
    end
  end

  def page
    if params[:page] == "1"
      redirect_to root_path unless params[:filter]
      redirect_to filter_path if params[:filter]
      return
    end

    unless params[:filter]
      @sample = Post.where(campaign_id: @campaign.id).order('posts.created_at DESC').offset((((params[:page].to_i - 1) * Post.per_page) + (200 - Post.per_page))).limit(1).first
      @filter = (params[:filter].nil? ? 'index' : params[:filter])

      @posts = Rails.cache.fetch @filter + '-page-' + params[:page].to_s + '/' + @sample.created_at.to_i.to_s do
        Post.where(campaign_id: @campaign.id).order('posts.created_at DESC').offset((((params[:page].to_i - 1) * Post.per_page) + (200 - Post.per_page)) + 1).limit(Post.per_page - 1).all
      end
      @posts.unshift @sample
      render :index
      return
    else
      @posts, @count, @last, @page, @admin = Post.get_scroll(@campaign, admin?, params, ((!params[:filter].empty? && params[:filter] != 'false') ? params[:filter] : 'index'), (!params[:filter].empty? && params[:filter] != 'false'))
      render :filter
      return
    end
  end

  def scroll
    if params[:filter] == 'index'
      @posts = get_posts((params[:page].to_i * Post.per_page), Post.per_page)
    else
      @posts, @count, @last, @page, @admin = Post.get_scroll(@campaign, admin?, params, ((!params[:filter].empty? && params[:filter] != 'false') ? params[:filter] : 'index'), (!params[:filter].empty? && params[:filter] != 'false'))
    end
  end

  # GET /:campaign/show/cats-NY
  def filter
    if Rails.application.config.filters[@campaign.path].nil?
      redirect_to :root
      return
    end

    begin
      @posts, @count, @last, @page, @admin = Post.get_scroll(@campaign, admin?, params, params[:filter], true)
      @filter = params[:filter]
    rescue => e
      logger.error("Exception: #{e.message}")
      redirect_to :root
      return
    end

    # expires_in 1.hour, public: true, 'max-style' => 0

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @posts, root: false }
    end
  end

  # GET /:campaign/mine
  # GET /:campaign/featured
  def extras
    @stats = Rails.application.config.stats[@campaign.path]
    
    @result = nil
    @where = {}
    @real_path = params[:filter] ||= Pathname.new(request.fullpath).basename.to_s.gsub(/\.[a-z]+/, '')
    @admin = ''
    @page = "0"

    @posts = Post.build_post(@campaign)
    if params[:run] == 'mine'
      @posts = @posts.where(:uid => session[:drupal_user_id]).order('created_at DESC')
    elsif params[:run] == 'featured'
      @posts = @posts.where(:promoted => true)
    end

    @filter = @real_path
    @count = @posts.length

    # Set up limit depending on scroll position
    @posts = @posts.scrolly(params[:last])

    @last = !@posts.last.nil? ? @posts.last.id : nil

    render :index
  end

  # Automatically uploads an image for the form.
  # POST /:campaign/posts/autoimg
  def autoimg
    valid_types = ['image/jpeg', 'image/gif', 'image/png']
    file = params[:file]

    # Make triple-y sure that we're uploading a valid file.
    if valid_types.include?(file.content_type)
      # Basic variables.
      path = file.tempfile.path()
      name = file.original_filename
      dir = 'public/system/tmp'

      if File.exists?(path) && File.exists?(dir)
        newfile = File.join(dir, name)
        File.open(newfile, 'wb') { |f| f.write(file.tempfile.read()) }
      # This shouldn't happen.
      else
        render json: {:success => false, :reason => "Your file didn't upload properly.  Try again."}
      end

      # Render success.
      render json: {:success => true, :filename => name}
    else
      render json: {:success => false, :reason => 'Not a valid file.'}
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Rails.cache.fetch 'campaign-' + @campaign.id.to_s + '-post-' + params[:id].to_s do
      Post
        .build_post(@campaign)
        .where(id: params[:id])
        .limit(1)
        .first
    end

    if @post.nil?
      redirect_to root_path
      return
    end

    expires_in 1.year, public: true, 'max-style' => 0

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
    end
  end

  # GET /:campaign/submit
  def new
    @post = Post.new
  end

  # GET /:campaign/posts/1/edit
  def edit
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    # Attempt to set the user ID
    if request.format.symbol != :json || authenticated?
      unless authenticated?
        flash[:error] = "Sorry, there was an error while submitting.  Please log in again and try again."
        redirect_to submit_path
        return false
      end
      params[:post][:uid] = session[:drupal_user_id]
    end

    require 'uri'
    if params[:post][:image] =~ URI::regexp
      real_filename = File.basename(params[:post][:image])
      tmp_file = Rails.root.to_s + '/public/tmp/' + real_filename

      File.open(tmp_file, 'wb') do |file|
        file.write open(params[:post][:image]).read
      end

      params[:post][:processed_from_url] = tmp_file
      params[:post][:image] = File.new(tmp_file)
    end

    if params[:post][:school_id] && (@campaign && @campaign.has_school_field === true)
      match = params[:post][:school_id].match(/\((?<gsid>\d+)\)/)

      # Force a failure if they've input a non-GS school
      if match && !match['gsid'].nil?
        params[:post][:school_id] = match['gsid']
      else
        params[:post][:custom_school] = params[:post][:school_id]
        params[:post][:school_id] = nil
      end
    end

    @post = Post.new(params[:post])
    respond_to do |format|
      if @post.save
        format.html { expire_pages; redirect_to show_post_path(@post, :campaign_path => @post.campaign.path) }
        format.json { render json: @post, status: :created }
      else
        format.html { render action: "new" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /posts/1
  # PUT /posts/1.json
  def update
    @post = Post.find(params[:id])

    require 'uri'
    if params[:post][:image] =~ URI::regexp
      real_filename = File.basename(params[:post][:image])
      tmp_file = Rails.root.to_s + '/public/tmp/' + real_filename

      File.open(tmp_file, 'wb') do |file|
        file.write open(params[:post][:image]).read
      end

      params[:post][:processed_from_url] = tmp_file
      params[:post][:image] = File.new(tmp_file)
    end

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { expire_pages; redirect_to show_post_path(@post, :campaign_path => @post.campaign.path), notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  def expire_pages
    expire_action(action: 'index', campaign_path: @campaign.path)
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  # POST /:campaign/posts/1/flag
  def flag
    list = Rails.cache.fetch 'index-first-posts' do
      Post.where(flagged: false).last(200).reverse.map(&:id)
    end

    # Mark this post as flagged
    post = Post.where(id: params[:id])
    if post.first
      post.first.update_attribute(:flagged, true)
    end

    if list.index(params[:id].to_i)
      Rails.cache.write 'index-first-posts', Post.where(flagged: false).last(200).reverse.map(&:id)
      Rails.cache.delete 'index-posts'
      expire_pages
    end

    redirect_to request.env['HTTP_REFERER']
  end

  # GET /:campaign/henri
  # Shows a post that is featured and has the same name as your search.
  def vanity
    @post = Rails.cache.fetch 'campaign-' + @campaign.id.to_s + 'vanity-' + params[:vanity].downcase do
      Post
        .build_post(@campaign)
        .where(promoted: true)
        .where('LOWER(name) = ?', params[:vanity].downcase)
        .limit(1)
        .first
    end

    if @post.nil?
      redirect_to root_path(campaign_path: @campaign.path)
    else
      render :show
    end
  end

  # POST /:campaign/posts/1/thumbs
  def thumbs
    # unless session[:drupal_user_id] > 0
    #   render json: { message: "You must be logged in to do that." }, status: 401
    # end

    user = User.find_by_uid(session[:drupal_user_id])
    post = Post.find(params[:id])
    if params[:type] == 'up'
      post.increment!(:thumbs_up_count)
    elsif params[:type] == 'down'
      post.increment!(:thumbs_down_count)
    end

    begin
      # Execute the vote
      color = user.perform_vote(params[:type], post)
    rescue
      color = false
    end

    score = post.plusminus
    up = post.thumbs_up_count
    down = post.thumbs_down_count

    popup = color ? get_popup : ""

    render :json => { score: score, up: up, down: down, color: color, popup: popup }
  end

  # GET /:campaign_path/posts/school_lookup?term=[term]
  # POST /:campaign_path/posts/school_lookup
  def school_lookup
    raise 'This campaign does not have a school field' unless @campaign.has_school_field

    # params[:term] = searchterm
    # params[:state] = state

    # Make a request to the GreatSchools search
    require 'open-uri'
    search = JSON.parse(open('http://lofischools.herokuapp.com/search?query=' + URI::escape(params[:term]) + '&state=' + URI::escape(params[:state])).read)['results']

    # Test data
    # search = [
    #   { 'gsid' => 1, 'name' => 'DoSomething High School', 'city' => 'Brooklyn', 'state' => 'NY', 'zip' => '11225' },
    #   { 'gsid' => 2, 'name' => 'Blah blah School', 'city' => 'Wesminster', 'state' => 'MD', 'zip' => '11225' }
    # ]

    starter = [{ label: params[:term], value: params[:term] }]
    results = search.inject(starter) do |res, elm|
      result = { label: elm['name'], value: "#{elm['name']} (#{elm['gsid']})" }

      begin
        # Store a local copy of the school so we can reference posts to its information.
        School.create({
          gsid: elm['gsid'],
          title: elm['name'],
          state: elm['state'],
          city: elm['city'],
          zip: elm['zip']
        })
      rescue
        # There's a unique key on GSID so School.create will fail sometimes.  Whatever!
      end

      res << result if result[:label] =~ Regexp.new(params[:term], 'i')
    end

    render json: results, root: false, response: 200
  end

  # POST /:campaign/posts/:id/share
  def share
    session[:drupal_user_id] ||= 0
    params[:share][:uid] = session[:drupal_user_id] unless params[:share][:uid]

    @share = Share.new(params[:share])
    Post.increment_counter(:share_count, params[:share][:post_id])

    # Get popup if applicable
    popup =
      if params[:share][:uid] && params[:share][:uid].to_i > 0
        get_popup
      else
        false
      end

    if @share.save
      render json: { success: true, popup: popup }, root: false, response: 200
    else
      begin
        # Forces an email to be sent if a share somehow fails.
        raise "Share failed with post ID #{params[:share][:post_id].to_s} and UID #{params[:share][:uid].to_s}"
      rescue
        render json: { success: false }
      end
    end
  end

  def uid_lookup
    @posts = Post.where(uid: params[:uid], campaign_id: @campaign.id)
    render json: @posts, root: false, response: 200
  end

  def get_counts
    @posts = Post
      .select('id, thumbs_up_count, thumbs_down_count, share_count')
      .where(id: params[:post_ids], campaign_id: @campaign.id)
      .all

    inj = @posts.inject({}) do |result, post|
      result[post.id] = {
        tu: post.thumbs_up_count,
        td: post.thumbs_down_count,
        sc: post.share_count || 0
      }
      result
    end

    render json: inj, root: false, response: 200
  end

  def stats_email
    unless ApiKey.find_by_key(params[:key])
      redirect_to root_path
      return false
    end

    campaign = Campaign.find_by_path(params[:campaign_path])
    posts_count = campaign.posts.where(flagged: false).count
    vote_count = campaign.posts.vote_count
    share_count = campaign.posts.share_count
    users_count = User.count

    Mailer.stats_email(users_count, posts_count, vote_count, share_count).deliver
    render text: 'Stats email sent', layout: false
  end
end
