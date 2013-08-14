class PostsController < ApplicationController
  include Services

  # Get campaign
  before_filter :get_campaign, only: [:campaign_closed, :index, :filter, :extras, :show, :vanity, :new]

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
    @promoted, @posts, @count, @last, @page, @admin = Post.get_scroll(@campaign, admin?, params, 'index')
    @user = User.find_by_uid(session[:drupal_user_id])

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @posts, root: false }
      format.csv { send_data Post.as_csv }
    end
  end

  # Automatically uploads an image for the form.
  def autoimg
    valid_types = ['image/jpeg', 'image/gif', 'image/png']
    file = params[:file]

    # Make tripl-y sure that we're uploading a valid file.
    if !valid_types.include?(file.content_type)
      render json: { :success => false, :reason => 'Not a valid file.' }
    else
      # Basic variables.
      path = file.tempfile.path()
      name = file.original_filename
      dir = 'public/system/tmp'

      # This shouldn't happen.
      if !File.exists? path
        render json: { :success => false, :reason => "Your file didn't upload properly.  Try again." }
      else
        # Write the file to the tmp directory.
        if File.exists? dir and File.exists? path
          newfile = File.join(dir, name)
          File.open(newfile, 'wb') { |f| f.write(file.tempfile.read()) }
        end
      end

      # Render success.
      render json: { :success => true, :filename => name }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post
      .build_post(@campaign)
      .where(id: params[:id])
      .limit(1)
      .first

    @user = User.find_by_uid(session[:drupal_user_id])

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
    render :status => :forbidden if !admin?

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

    @post = Post.find(params[:id])
    @post.flagged = true
    @post.save

    redirect_to request.env['HTTP_REFERER']
  end

  # GET /:campaign/henri
  def vanity
    @post = Post
      .build_post(@campaign)
      .where(promoted: true)
      .where('LOWER(name) = ?', params[:vanity].downcase)
      .limit(1)
      .first

    if @post.nil?
      redirect_to root_path(campaign_path: @campaign.path)
    else
      render :show
    end
  end

  # GET /:campaign/show/cats-NY
  def filter
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
    @user = User.find_by_uid(session[:drupal_user_id])
    
    @result = nil
    @where = {}
    @real_path = params[:filter] ||= Pathname.new(request.fullpath).basename.to_s.gsub(/\.[a-z]+/, '')
    @admin = ''
    @page = 0.to_s

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

    color = true

    if params[:type] == 'up'
      if !user.voted_on?(post)
        user.vote_for(post)
      elsif user.voted_against?(post)
        user.vote_exclusively_for(post)
      else
        user.unvote_for(post)
        color = false
      end
    else
      if !user.voted_on?(post)
        user.vote_against(post)
      elsif user.voted_for?(post)
        user.vote_exclusively_against(post)
      else
        user.unvote_for(post)
        color = false
      end
    end

    score = post.plusminus
    up = post.votes_for
    down = post.votes_against

    popup = color ? get_popup : ""

    render :json => { score: score, up: up, down: down, color: color, popup: popup }
  end

  def school_lookup
    #require 'open-uri'
    #require 'json'
    #base_uri = 'http://localhost:3000'
    #res = JSON.parse(open('http://mchitten.com/articles.json').read)
    search = [
      { gsid: 1, name: 'DoSomething High School', city: 'Brooklyn', state: 'NY', zip: '11225' },
      { gsid: 2, name: 'Blah blah School', city: 'Wesminster', state: 'MD', zip: '11225' }
    ]

    mapped = search.map { |e| { label: e[:name], value: "#{e[:name]} (#{e[:gsid]})" } }
    results = mapped.find_all { |result| result[:label] =~ Regexp.new(params[:term], 'i') }

    render json: results, root: false, response: 200
  end
end
