class PostsController < ApplicationController
  include Services

  # Get campaign
  before_filter :get_campaign, except: [:autoimg, :edit, :update, :destroy, :flag, :thumbs]
  before_filter :get_user, only: [:index, :show, :filter, :vanity, :extras]

  # Before everything runs, run an authentication check and an API key check.
  before_filter :is_not_authenticated, :verify_api_key, :campaign_closed
  skip_before_filter :campaign_closed, only: [:create, :update]

  # Ignores xsrf in favor of API keys for JSON requests.
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # Shows the static (closed) gallery when a campaign is finished, or not started yet.
  def campaign_closed
    now = Time.now
    if @campaign && (@campaign.start_date > now || @campaign.end_date < now)
      render 'static_pages/gallery'
      return
    end
  end

  # GET /posts
  # GET /posts.json
  def index
    @stats = Rails.application.config.stats[@campaign.path]
    @promoted, @posts, @count, @last, @page, @admin = Post.get_scroll(@campaign, admin?, params, 'index')

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @posts, root: false }
      format.csv { send_data Post.as_csv }
    end
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

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
      format.csv { send_data @post.as_csv }
    end
  end

  # GET /:campaign/submit
  def new
    @post = Post.new
  end

  # GET /:campaign/posts/1/edit
  def edit
    # Shouldn't be here if they're not an admin.
    render status: :forbidden unless admin?
    @post = Post.find(params[:id])
  end

  # POST /posts
  # POST /posts.json
  def create
    # Attempt to set the user ID
    if request.format.symbol != :json || authenticated?
      render :status => :forbidden unless authenticated?
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
        params[:post][:school_id] = nil
      end
    end

    @post = Post.new(params[:post])
    respond_to do |format|
      if @post.save
        format.html { redirect_to show_post_path(@post, :campaign_path => @post.campaign.path) }
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
    # Shouldn't be here if they're not an admin.
    render status: :forbidden unless admin?

    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to show_post_path(@post, :campaign_path => @post.campaign.path), notice: 'Post was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /posts/1
  # DELETE /posts/1.json
  def destroy
    # Shouldn't be here if they're not an admin.
    render :status => :forbidden unless admin?

    @post = Post.find(params[:id])
    @post.destroy

    respond_to do |format|
      format.html { redirect_to posts_url }
      format.json { head :no_content }
    end
  end

  # POST /:campaign/posts/1/flag
  def flag
    # Shouldn't be here if they're not an admin.
    render status: :forbidden unless admin?

    # Mark this post as flagged
    Post.find(params[:id]).update_attribute(:flagged, true)

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

  # GET /:campaign/show/cats-NY
  def filter
    @stats = Rails.application.config.stats[@campaign.path]
    if Rails.application.config.filters[@campaign.path].nil?
      redirect_to :root
      return
    end

    begin
      @promoted, @posts, @count, @last, @page, @admin = Post.get_scroll(@campaign, admin?, params, params[:filter], true)
      @filter = params[:filter]
    rescue => e
      logger.error("Exception: #{e.message}")
      redirect_to :root
      return
    end

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @posts, root: false }
      format.csv { send_data Post.as_csv }
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
      @posts = @posts.where(:uid => session[:drupal_user_id])
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

  # POST /:campaign/posts/1/thumbs
  def thumbs
    user = User.find_by_uid(session[:drupal_user_id])
    post = Post.find(params[:id])

    # Execute the vote
    color = user.perform_vote(params[:type], post)

    score = post.plusminus
    up = post.votes_for
    down = post.votes_against

    popup = color ? get_popup : ""

    render :json => { score: score, up: up, down: down, color: color, popup: popup }
  end

  # GET /:campaign_path/posts/school_lookup?term=[term]
  # POST /:campaign_path/posts/school_lookup
  def school_lookup
    unless @campaign.has_school_field
      raise 'This campaign does not have a school field'
    end

    #require 'open-uri'
    #require 'json'
    #base_uri = 'http://localhost:3000'
    #res = JSON.parse(open('http://mchitten.com/articles.json').read)
    search = [
      { gsid: 1, name: 'DoSomething High School', city: 'Brooklyn', state: 'NY', zip: '11225' },
      { gsid: 2, name: 'Blah blah School', city: 'Wesminster', state: 'MD', zip: '11225' }
    ]

    results = search.inject([]) do |res, elm|
      result = { label: elm[:name], value: "#{elm[:name]} (#{elm[:gsid]})" }
      res << result if result[:label] =~ Regexp.new(params[:term], 'i')
      res
    end

    render json: results, root: false, response: 200
  end

  # POST /:campaign/posts/:id/share
  def share
    render status: :forbidden unless (request.format.symbol == :json || authenticated?)

    # Uy populating UID through mobile request
    params[:share][:uid] = session[:drupal_user_id] unless request.format.symbol == :json

    @share = Share.new(params[:share])
    Post.increment_counter(:share_count, params[:share][:post_id])

    # Get popup if applicable
    popup = get_popup

    respond_to do |format|
      if @share.save
        format.html { render json: { 'success' => true, popup: popup } }
        format.json { render json: { 'success' => true, popup: popup } }
      else
        format.html { render json: { 'success' => false, popup: popup } }
        format.json { render json: { 'success' => false, popup: popup } }
      end
    end
  end
end
