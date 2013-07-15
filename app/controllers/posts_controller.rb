class PostsController < ApplicationController
  include Services
  include PostsHelper

  # Before everything runs, run an authentication check and an API key check.
  before_filter :is_not_authenticated, :verify_api_key, :campaign_closed

  # Ignores xsrf in favor of API keys for JSON requests.
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  # Shows the static (closed) gallery when a campaign is finished, or not started yet.
  def campaign_closed
    now = Time.now
    if $campaign.start_date > now || $campaign.end_date < now
      render 'static_pages/gallery'
      return
    end
  end

  # GET /posts
  # GET /posts.json
  def index
    @admin = ''
    @admin = 'admin-' if admin?
    @admin += $campaign.path

    campaign_id = $campaign.id

    # Get the page and offset
    page = params[:page] || 0
    offset = (page.to_i * Post.per_page)

    # Basic post query.
    @p = Post.infinite_scroll($campaign.id).limit(Post.per_page)
    @sb_promoted = Rails.cache.fetch @admin + 'posts-index-promoted' do
      Post
        .joins('LEFT JOIN shares ON shares.post_id = posts.id')
        .select('posts.*, COUNT(shares.*) AS real_share_count')
        .group('posts.id')
        .where(:promoted => true, :flagged => false, :campaign_id => campaign_id)
        .order('RANDOM()')
        .limit(1)
        .all
        .first
    end

    if !params[:last].nil?
      # We're on a "page" of the infinite scroll.  Load the cache for that page.
      @posts = Rails.cache.fetch @admin + 'posts-index-before-' + params[:last] do
      @p
        .where('posts.id < ?', params[:last])
        .where('posts.id != ?', (!@sb_promoted.nil? ? @sb_promoted.id : 0))
        .all
      end
    else
      # We're on the first "page" of the infinite scroll.  Load the cache for
      # promoted, the posts, and the total count.
      @promoted = @sb_promoted
      @posts = Rails.cache.fetch @admin + 'posts-index' do
      @p
        .where(:promoted => false)
        .limit(Post.per_page - 1)
        .all
      end
      @count = Rails.cache.fetch @admin + 'posts-index-count' do
        Post
          .where(:flagged => false)
          .all
          .count
      end
    end

    # The ID of the last post on the page.
    @last = 0
    if !@posts.last.nil?
      @last = @posts.last.id
    end
    # The page.
    @page = page.to_s

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

  # GET /alterimg/1
  # Alters image by adding top and bottom text, within semi-transparent block.
  def alterimg
    # We need to be an administrator to be here.
    if !admin?
      redirect_to :root
    end

    # Find the post and the image associated with it.
    @post = Post.find(params[:id])
    image = @post.image.url(:gallery)
    image = '/public' + image.gsub(/\?.*/, '')

    # Rewrite the image.
    if File.exists? Rails.root.to_s + image
      PostsHelper.image_writer(image, @post.meme_text, @post.meme_position)
    end

    respond_to do |format|
      format.html { redirect_to show_post_path(@post) }
    end
  end

  # GET /fix
  # Fixes all images should they lose their text.
  def fix
    # Must be an admin to do this.
    if !admin?
      redirect_to :root
    end

    # Get all posts.
    @posts = Post.all
    @posts.each do |post|
      # Get the actual image path.
      image = post.image.url(:gallery)
      image = '/public' + image.gsub(/\?.*/, '')

      # Assuming the file exists, write the text.
      if File.exists? Rails.root.to_s + image
        PostsHelper.image_writer(image, post.meme_text, meme_position)
      end
    end

    respond_to do |format|
      format.html { redirect_to :root, notice: "Images fixed." }
    end
  end

  # GET /posts/1
  # GET /posts/1.json
  def show
    @post = Post
      .infinite_scroll($campaign.id)
      .where(:id => params[:id])
      .limit(1)
      .first

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @post }
      format.csv { send_data @post.as_csv }
    end
  end

  # GET /posts/new
  def new
    @post = Post.new

    respond_to do |format|
      format.html # new.html.erb
    end
  end

  # GET /posts/1/edit
  def edit
    # Shouldn't be here if they're not an admin.
    if !admin?
      redirect_to :root
    end

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

    @post = Post.new(params[:post])

    respond_to do |format|
      if @post.save
        format.html { redirect_to show_post_path(@post, :campaign_path => $campaign.path) }
        format.json { render json: @post, status: :created, location: @post }
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
    render :status => :forbidden if !admin?

    @post = Post.find(params[:id])

    respond_to do |format|
      if @post.update_attributes(params[:post])
        format.html { redirect_to show_post_path(@post, :campaign_path => $campaign.path), notice: 'Post was successfully updated.' }
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

  # GET /flag/1
  def flag
    # Shouldn't be here if they're not an admin.
    render :status => :forbidden unless admin?

    @post = Post.find(params[:id])
    @post.flagged = true
    @post.save

    respond_to do |format|
      format.html { redirect_to request.env["HTTP_REFERER"] }
    end
  end

  def vanity
    @post = Post
      .joins('LEFT JOIN shares ON shares.post_id = posts.id')
      .select('posts.*, COUNT(shares.*) AS real_share_count')
      .where(:promoted => true, :flagged => false, :campaign_id => $campaign.id)
      .where('LOWER(name) = ?', params[:vanity])
      .group('posts.id')
      .limit(1)
      .first

    if @post.nil?
      redirect_to :root
    else
      render :controller => 'posts', :action => 'show', :campaign_path => $campaign.path
    end
  end

  def show_filter
    @result = nil
    @where = {}
    @real_path = params[:filter] ||= Pathname.new(request.fullpath).basename.to_s.gsub(/\.[a-z]+/, '')
    @admin = ''
    @page = 0.to_s

    if Rails.application.config.filters[params[:campaign_path]].nil?
      redirect_to :root
      return
    end

    Rails.application.config.filters[params[:campaign_path]].each do |route, config|
      ret = route
      unless config['constraints'].nil?
        config['constraints'].each do |key, constraint|
          ret = ret.gsub(key, constraint)
        end
      end

      ret = Regexp.new "^#{ret}$"
      if @result = @real_path.match(ret)
        @where = config['where']
        break
      end
    end

    if @result.nil?
      redirect_to :root
      return
    end

    # Page and offset.
    page = params[:page] || 0
    offset = (page.to_i * Post.per_page)
    @scrolling = !params[:last].nil?

    cols = Post.column_names
    @posts = Post.infinite_scroll($campaign.id)
    i = 0
    @where.each do |column, value|
      if cols.include? column
        if @result.names.length > 0
          if !@result[value].nil?
            @posts = @posts.where(column.to_sym => @result[value])
          end
        else
          @posts = @posts.where(column.to_sym => value)
        end
      else
        col_alias = "t#{i.to_s}"
        if @result.names.length > 0
          if !@result[value].nil?
            value = @result[value]
          end
        else
          value = value
        end

        @posts = @posts
          .joins('INNER JOIN tags ' + col_alias + ' ON (' + col_alias + '.post_id = posts.id)')
          .where(col_alias + '.column = ? and ' + col_alias + '.value = ?', column, value)
        i += 1
      end
    end

    @filter = @real_path
    @count = @posts.length

    # Set up limit depending on scroll position
    @posts = @posts.scrolly(params[:last])

    @last = !@posts.last.nil? ? @posts.last.id : nil

    respond_to do |format|
      format.js
      format.html # index.html.erb
      format.json { render json: @posts, root: false }
      format.csv { send_data Post.as_csv }
    end
  end

  def extras
    @result = nil
    @where = {}
    @real_path = params[:filter] ||= Pathname.new(request.fullpath).basename.to_s.gsub(/\.[a-z]+/, '')
    @admin = ''
    @page = 0.to_s

    # Page and offset.
    page = params[:page] || 0
    offset = (page.to_i * Post.per_page)
    @scrolling = !params[:last].nil?

    @posts = Post.infinite_scroll($campaign.id)
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

  # POST /posts/:id/thumbs_up
  def thumbs_up
    post = Post.increment_counter(:thumbs_up_count, params[:id])
    render json: { success: true }
  end

  # POST /posts/:id/thumbs_down
  def thumbs_down
    post = Post.increment_counter(:thumbs_down_count, params[:id])
    render json: { success: true }
  end
end
