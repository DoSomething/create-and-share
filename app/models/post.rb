class Post < ActiveRecord::Base
  attr_accessible :uid, :adopted, :creation_time,
    :flagged, :image, :name, :promoted,
    :share_count, :state, :city,
    :story, :update_time,
    :meme_text, :meme_position,
    :crop_x, :crop_y, :crop_w, :crop_h, :crop_dim_w,
    :campaign_id, :extras, :processed_from_url,
    :school_id, :custom_school, :thumbs_up_count, :thumbs_down_count

  # Contains all custom fields for a campaign
  serialize :extras, Hash

  # Processing -- cropping and so forth
  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h,
    :reprocessed, :crop_dim_w, :real_share_count,
    :processed_from_url

  validates :name,    :presence => true
  validates :city,    :format => { :with => /[A-Za-z0-9\-\_\s]+/ },
                      :allow_blank => true
  validates :school_id,  :presence => { :if => :is_school_campaign? }
  validates :state,   :presence => true,
                      :length => { :maximum => 2 },
                      :format => { :with => /[A-Z]{2}/ }
  validates :campaign_id, :presence => true, :numericality => true

  has_attached_file :image, :styles => { :gallery => '450x450!' }, :default_url => '/images/:style/default.png', :processors => [:cropper, :memify, :compress]
  validates_attachment :image, :presence => true, :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif', 'image/pjpeg', 'image/x-png'] }

  has_many :shares
  has_many :tags
  belongs_to :campaign
  belongs_to :user, foreign_key: 'uid', primary_key: 'uid'
  belongs_to :school, primary_key: 'gsid'

  has_many :votes, as: :voteable
  acts_as_voteable

  # Make sure we're not attempting to save a school when it doesn't ask for one
  before_save do
    if !is_school_campaign? && self.school_id
      self.school_id = nil
    end
  end

  def self.vote_count
    Vote.where(voteable_id: self.all.map(&:id)).count
  end
  def self.share_count
    Share.where(post_id: self.all.map(&:id)).count
  end

  # See if the current campaign is a school campaign
  def is_school_campaign?
    return false if self.campaign_id.nil?

    campaign = Campaign.find(self.campaign_id)
    campaign.has_school_field === true && !self.custom_school
  end

  # Filters posts for a specific custom field.
  # Example:
  #   Post.tagged(:animal_type => 'cat')
  #
  # ...because "animal_type" is a custom field, we need to inner join
  # our connecting "tags" relation to filter posts properly.
  def self.tagged(*args)
    args = args[0]

    i = 0
    @p = args.inject(self) do |query, join|
      join_alias = "t#{i}"
      query = query
        .joins("INNER JOIN tags #{join_alias} ON (#{join_alias}.post_id = posts.id)")
        .where("#{join_alias}.campaign_id = posts.campaign_id AND (#{join_alias}.column = ? AND #{join_alias}.value = ?)", join[0], join[1])

      i += 1
      query
    end

    @p
  end

  # The number of elements to show per "page" in the infinite scroll.
  def self.per_page
    16
  end

  # Sets up the basic infinite scroll query.
  def self.build_post(campaign)
    self
      .select('(posts.thumbs_up_count + posts.thumbs_down_count) AS vc')
      .joins('LEFT JOIN schools ON (schools.gsid = posts.school_id)')
      .where(campaign_id: campaign.id, flagged: false)
      .group('posts.id')
      .includes(:school)
  end

  # Builds the entire infinite scroll based on custom criteria, if applicable,
  # or defaults if not.
  #
  # @param [Object] campaign
  #   A campaign object relating to the current campaign.
  # @param [bool] admin
  #   Whether or not the current user is an administrator.  We cache the admin
  #   version separately because of edit links, etc.
  # @param [Object] params
  #   The params object exactly as it is in the controller action.
  # @param [String] state
  #   Either 'index' or a particular filter to use to filter the posts.
  # @param [bool] filtered
  #   Whether the current scroll is filtered.
  #
  # @return [Object]
  #   An array of returned data:
  #   promoted: The promoted post for this page, if applicable.
  #   cached_posts: The cached version of the posts for this page.
  #   total: The number of posts, in total
  #   last: The ID of the last post on this particular page
  #   params[:page].to_s: The current page.
  #   prefix: A prefix for caching on a per-campaign basis.
  #
  # @see PostsController
  def self.get_scroll(campaign, admin, params, state, filtered = false)
    # Used for caching -- admins and regular users have two different versions
    # Also includes the campaign ID
    prefix = admin ? 'admin-' : ''
    prefix += campaign.id.to_s + '-' + state + '-'

    # Default page is always 0
    params[:page] ||= 0

    # Set up the basic query.
    uncached_posts = self
      .build_post(campaign)
      .order('posts.created_at DESC')

    # If we're on the index page, we can set up overrides through the config file.
    if state == 'index'
      if !Rails.application.config.home[params[:campaign_path]].nil?
        home_config = Rails.application.config.home[params[:campaign_path]]
        # Make sure we don't bug out.
        home_config['fields'] ||= {}
        home_config['joins'] ||= {}
        home_config['where'] ||= {}
        home_config['order'] ||= {}

        # Set up some overrides / additions to th equery
        uncached_posts = uncached_posts.build_config_params(uncached_posts, {}, home_config['fields'], home_config['joins'], home_config['where'], home_config['order'])
      end
    end

    # If we're on a filtered page, set up the filters
    if filtered
      uncached_posts = uncached_posts
        .filtered(params)
    end

    # If we're NOT on a filtered page, we likely have a promoted post to show.
    if !filtered
      promoted = Rails.cache.fetch prefix + 'posts-' + state + '-promoted' do
        self
          .build_post(campaign)
          .where(:promoted => true)
          .order('RANDOM()')
          .limit(1)
          .all
          .first
      end
    else
      promoted = nil
    end

    # If we're on a "page" of the infinite scroll...
    if !params[:last].nil?
      # ...and we have more than one ORDER BY clause, we need to do
      # the scroll the old fashioned way
      if params[:type] == 'custom'
        cached_posts = Rails.cache.fetch prefix + 'posts-' + state + '-before-' + params[:last] do
          uncached_posts
            .offset((params[:page].to_i * self.per_page))
            .limit(self.per_page)
            .all
        end
      else
        # Otherwise we can do the scroll the proper way
        cached_posts = Rails.cache.fetch prefix + 'posts-' + state + '-before-' + params[:last] do
          uncached_posts
            .where('posts.id < ?', params[:last])
            .where('posts.id != ?', promoted ? promoted.id : 0)
            .limit(self.per_page)
            .all
        end
      end
    # Otherwise we're on the front page.
    else
      # Get a cached version of the post query
      limit = (promoted ? (self.per_page - 1) : self.per_page)
      cached_posts = Rails.cache.fetch prefix + 'posts-' + state do
        uncached_posts
          .limit(limit)
          .all
      end

      # Get totals for this campaign
      if !filtered
        total = Rails.cache.fetch prefix + 'posts-' + state + '-count' do
          self
            .where(flagged: false, campaign_id: campaign.id)
            .count
        end
      else
        total = Rails.cache.fetch prefix + 'posts-' + state + '-count' do
          self
            .where(flagged: false, campaign_id: campaign.id)
            .filtered(params)
            .count
        end
      end
    end

    # Assuming there's a last post (there may not be if there are no posts),
    # remember that post's ID
    if !cached_posts.last.nil?
      last = cached_posts.last.id
    end
    last ||= nil

    [promoted, cached_posts, total, last, params[:page].to_s, prefix]
  end

  # Alters the query to filter by a specific field
  # @param [Object] params
  #   The parameters from the controller action, as passed through get_scroll, above.
  def self.filtered(params)
    return self if params[:action] == 'index'

    # Get filters for the current campaign.
    Rails.application.config.filters[params[:campaign_path]].each do |route, config|
      ret = route

      # If there are constraints to speak of, replace any tokens in the filter
      # with those constraints.
      # As an example:
      #
      # "show-by-:state-state":
      #   constraints:
      #     ":state": "(?<state>[A-Z]{2})"
      #
      # ...would change "show-by-:state-state" to "show-by-(?<state>[A-Z]{2})-state".
      # This allows us to attempt to match the current path.
      unless config['constraints'].nil?
        config['constraints'].each do |key, constraint|
          ret = ret.gsub(key, constraint)
        end
      end

      # Make our newly constrained filter a regular expression.
      ret = Regexp.new "^#{ret}$"

      # Attempt to match the current path with that regular expression.  If it
      # passes, get the proposed where, order, fields and joins from the filter file.
      if @result = params[:filter].match(ret)
        @where = config['where']
        @order = config['order']
        @fields = config['fields']
        @joins = config['joins']

        # Break out of the loop because we got what we need.
        break
      end
    end

    # If we didn't find any matching filter, raise an exception that will be
    # caught in PostsController#filter, which will redirect to the homepage.
    if @result.nil?
      raise
      return
    end

    # Alter the query to honor any query change we asked for in the config file
    self.build_config_params(self, @result, @fields, @joins, @where, @order)
  end

  # Alters a query to honor changes specified in a configuration file
  #
  # @param [Object] query
  #   The unfinished ActiveRecord query object, as it currently stands.
  # @param [Object] result
  #   If applicable, the filtered match() result object (from self.filterd(), above).
  # @param [Array] fields
  # @param [Array] join
  # @param [Array] where
  # @param [Array] order
  #   Arrays of fields / joins / where / order changes that are specified in a
  #   configuration file.
  #
  # @return [Object]
  #   The newly minted ActiveRecord query object, with the specified changes.
  def self.build_config_params(query, result = {}, fields = [], joins = [], where = [], order = [])
    cols = Post.column_names
    i = 0
    results = self

    # Additional fields.  You can add these by using the "fields" key in the
    # configuration file.
    #
    # "thumbsup-:state":
    #   fields:
    #     - "COUNT(up.*) as upcount"
    unless fields.nil?
      results = results.select('posts.*')
      fields.each do |f|
        results = results.select(f)
      end
    end

    # Additional joins.  You can add these by using the "joins" key in the
    # configuration file.  All joins need to be completely written out.
    #
    # "thumbsup-:state"
    #   joins:
    #     - "LEFT JOIN votes up on (up.voteable_id = posts.id and up.vote = 't')"
    unless joins.nil?
      joins.each do |j|
        results = results.joins(j)
      end
    end

    # Additional "where" conditions.  You can add these by using the "where" key
    # in the configuration file.  The key must always specify a valid field name,
    # and the value must be a string.
    #
    # "show-by-:state-state":
    #   where:
    #     "state": "state"
    #
    # "where" conditions' values are unique in that they can read from the current path
    # *or* be a custom string.  That depends on what you've specified in constraints.
    #
    # Going back to the state example found above, with constraints:
    # "show-by-:state-state":
    #   ...
    #   constraints:
    #     ":state": "(?<state>[A-Z]{2})"
    #
    # ...the constraints here, again, change the filter itself to "show-by-(?<state>[A-Z]{2})-state",
    # which is successfully matched if, for example, someone goes to /show/show-by-NY-state.  Because
    # the regular expression has a named reference ("(?<state>[A-Z]{2})"), the match() method in
    # self.filtered() will return :state => "NY"
    #
    # In the "where" condition above, notice that "state" is equal to "state" (by YAML standards).
    # This is important because the value "state" happens to be the same as the named reference
    # found in the constraints ("(?<state>...").  If this method ever finds a where value equal to
    # a named reference, it replaces the where value with the value of that regular expression match.
    #
    # So, if someone went to /show/show-by-NY-state, the regular expression would say that "state" => "NY".
    # This would basically change the "where" statement above to this:
    # where:
    #   "state": "NY"
    #
    # ...and, finally, produce this query:
    #   Post.where(:state => "NY")
    #
    # ALTERNATELY, if the "where" condition value is NOT the same as any named reference in constraints,
    # it assumes the value is already what you want it to be.  So if you said:
    # where:
    #   "state": "FL"
    #
    # This would produce this query, regardless of what the filter says:
    #   Post.where(:state => "FL")
    unless where.nil?
      # Loop through all where conditions...
      where.each do |column, value|
        # If the specified field (key) is a real Post column...
        if cols.include? column
          # If the result hash is not empty...
          if !result.nil? && !result.names.nil? && result.names.length > 0
            # And the result hash has a value for this specific key...
            if !result[value].nil?
              # Create a where!
              results = results.where(column.to_sym => result[value])
            end
          else
            # Otherwise, assume that the value is literal.
            results = results.where(column.to_sym => value)
          end
        # If the specified field (key) is NOT a real Post column, we can assume
        # it's a custom field.
        else
          # Create a colum alias
          col_alias = "t#{i.to_s}"
          # If the result hash is not empty...
          if !result.nil? && !result.names.nil? && result.names.length > 0
            # And the result hash has a value for this specific key...
            if !result[value].nil?
              # We want to filter by that value.
              value = result[value]
            end
          else
            # Otherwise, assume that the value is literal.
            value = value
          end

          # Inner join the tags (custom fields) table on column / value.
          # This ensure that the post meets those filtered criteria.
          results = results
            .joins('INNER JOIN tags ' + col_alias + ' ON (' + col_alias + '.post_id = posts.id)')
            .where(col_alias + '.column = ? and ' + col_alias + '.value = ?', column, value)
          i += 1
        end
      end
    end

    # Additional "order by" clauses.  You can add these by using the "order" key
    # in the configuration file.  All "order by"s need to be completely written out.
    #
    # "thumbsup-:state"
    #   order:
    #     - "created_at DESC"
    #     - "name DESC"
    unless order.nil? || order.count == 0
      results = results.reorder('')
      order.each do |o|
        results = results.order(o)
      end
    end

    # Return the altered query
    results
  end

  # Sets up basic scrolly functionality specifically for "mine" and "featured" pages
  # @todo Remove this in favor of the proper way.
  def self.scrolly(point = nil)
    # Finish the posts query given the "page" of the infinite scroll.
    if !point.nil?
      self
        .where('"posts"."id" < ?', point)
        .limit(Post.per_page - 1)
    else
      self
        .limit(Post.per_page - 1)
        .all
    end
  end

  # Removes HTML tags.  This technically will automatically be sanitized,
  # but better safe than sorry.
  before_save :strip_tags
  def strip_tags
    self.name = self.name.gsub(/\<[^\>]+\>/, '')
    if !self.meme_text.nil?
      self.meme_text = self.meme_text.gsub(/\<[^\>]+\>/, '')
      self.meme_text = self.meme_text.gsub(/'/, "'\"\'\"'")
    end
  end

  # Allows export-as-csv
  def self.as_csv
    CSV.generate do |csv|
      csv << column_names
      all.each do |item|
        csv << item.attributes.values_at(*column_names)
      end
    end
  end

  # Returns the total share count for a particular post.
  def total_shares
    self.shares.count
  end

  # Clears cache after a new post.
  after_create :touch_cache
  def touch_cache
    # We need to clear all caches -- Every cache depends on the one before it.
    Rails.cache.clear
  end

  after_create :send_thx_email
  # Sends the "thanks for reporting back" email.
  def send_thx_email
    @user = User.where(:uid => self.uid).first
    if !@user.nil? && !@user.email.nil?
      if !self.campaign.email_submit.nil?
        Services::Mandrill.mail(self.campaign.lead, self.campaign.lead_email, @user.email, self.campaign.email_submit)
      end
    end
  end

  # If we've sent a URL to an image instead of a File object,
  # we copied over the image into a tmp directory.  Delete it.
  after_create :remove_url_tmp_image, if: :loading_from_url?

  def loading_from_url?
    !self.processed_from_url.nil?
  end

  def remove_url_tmp_image
    if File.exists?(self.processed_from_url)
      FileUtils.rm_f(self.processed_from_url)
    end
  end

  # When a user fills out the form it uploads a temporary image.
  # Delete it.
  after_create :remove_real_tmp_image, unless: :loading_from_url?
  def remove_real_tmp_image
    filename = self.image.instance['image_file_name']
    dir = 'public/system/tmp/'

    if File.exists?(dir + filename)
      FileUtils.rm(dir + filename)
    end
  end

  # Crop the image!
  after_save :reprocess_image, :if => :reprocessing?
  def reprocessing?
    if self.reprocessed.nil?
      !self.crop_x.blank? && !self.crop_y.blank? && !self.crop_w.blank? && !self.crop_h.blank?
    end
  end

  # Load the file for geometric cropping
  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.path(style))
  end

  private

  # Needed by paperclip to reprocess the image.
  def reprocess_image
    image.reprocess!
  end
end
