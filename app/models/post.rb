class Post < ActiveRecord::Base
  attr_accessible :uid, :adopted, :creation_time,
    :flagged, :image, :name, :promoted,
    :share_count, :state, :city,
    :story, :update_time,
    :meme_text, :meme_position,
    :crop_x, :crop_y, :crop_w, :crop_h, :crop_dim_w,
    :campaign_id, :extras, :processed_from_url,
    :school_id

  serialize :extras, Hash

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

  has_attached_file :image, :styles => { :gallery => '450x450!' }, :default_url => '/images/:style/default.png', :processors => [:cropper, :memify]
  validates_attachment :image, :presence => true, :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  has_many :shares
  belongs_to :campaign
  belongs_to :user, foreign_key: 'uid', primary_key: 'uid'
  belongs_to :school, primary_key: 'gsid'

  acts_as_voteable

  before_save do
    if !is_school_campaign? && self.school_id
      self.school_id = nil
    end
  end

  def is_school_campaign?
    return false if self.campaign_id.nil?

    campaign = Campaign.find(self.campaign_id)
    campaign.has_school_field === true
  end

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
    10
  end

  def self.build_post(campaign)
    self
      .select('posts.*, COUNT(shares.*) AS real_share_count')
      .joins('LEFT JOIN shares ON (shares.post_id = posts.id)')
      .joins('LEFT JOIN votes ON (votes.voteable_id = posts.id)')
      .where(campaign_id: campaign.id, flagged: false)
      .group('posts.id')
  end

  def self.get_scroll(campaign, admin, params, state, filtered = false)
    prefix = admin ? 'admin-' : ''
    prefix += campaign.id.to_s + '-' + state + '-'

    params[:page] ||= 0

    uncached_posts = self
      .build_post(campaign)
      .order('created_at DESC')

    if state == 'index'
      if !Rails.application.config.home[params[:campaign_path]].nil?
        home_config = Rails.application.config.home[params[:campaign_path]]
        # Make sure we don't bug out.
        home_config['fields'] ||= {}
        home_config['joins'] ||= {}
        home_config['where'] ||= {}
        home_config['order'] ||= {}

        uncached_posts = uncached_posts.build_config_params(uncached_posts, {}, home_config['fields'], home_config['joins'], home_config['where'], home_config['order'])
      end
    end

    if filtered
      uncached_posts = uncached_posts
        .filtered(params)
    end

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

    if !params[:last].nil?
      cached_posts = Rails.cache.fetch prefix + 'posts-' + state + '-before-' + params[:last] do
        uncached_posts
          .where('posts.id < ?', params[:last])
          .where('posts.id != ?', promoted ? promoted.id : 0)
          .limit(self.per_page)
          .all
      end
    else
      cached_posts = Rails.cache.fetch prefix + 'posts-' + state do
        uncached_posts
          .limit(self.per_page - 1)
          .all
      end

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

    if !cached_posts.last.nil?
      last = cached_posts.last.id
    end
    last ||= nil

    [promoted, cached_posts, total, last, params[:page].to_s, prefix]
  end

  def self.filtered(params)
    Rails.application.config.filters[params[:campaign_path]].each do |route, config|
      ret = route
      unless config['constraints'].nil?
        config['constraints'].each do |key, constraint|
          ret = ret.gsub(key, constraint)
        end
      end

      ret = Regexp.new "^#{ret}$"
      if @result = params[:filter].match(ret)
        @where = config['where']
        @order = config['order']
        @fields = config['fields']
        @joins = config['joins']
        break
      end
    end

    if @result.nil?
      raise
      return
    end

    self.build_config_params(self, @result, @fields, @joins, @where, @order)
  end

  def self.build_config_params(query, result = {}, fields = [], joins = [], where = [], order = [])
    cols = Post.column_names
    i = 0
    results = self

    unless fields.nil?
      results = results.select('posts.*')
      fields.each do |f|
        results = results.select(f)
      end
    end

    unless joins.nil?
      joins.each do |j|
        results = results.joins(j)
      end
    end

    unless where.nil?
      where.each do |column, value|
        if cols.include? column
          if !result.nil? && !result.names.nil? && result.names.length > 0
            if !result[value].nil?
              results = results.where(column.to_sym => result[value])
            end
          else
            results = results.where(column.to_sym => value)
          end
        else
          col_alias = "t#{i.to_s}"
          if !result.nil? && !result.names.nil? && result.names.length > 0
            if !result[value].nil?
              value = result[value]
            end
          else
            value = value
          end

          results = results
            .joins('INNER JOIN tags ' + col_alias + ' ON (' + col_alias + '.post_id = posts.id)')
            .where(col_alias + '.column = ? and ' + col_alias + '.value = ?', column, value)
          i += 1
        end
      end
    end

    unless order.nil? || order.count == 0
      results = results.reorder('')
      order.each do |o|
        results = results.order(o)
      end
    end

    results
  end

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

  def total_shares
    self.shares.count
  end

  # Clears cache after a new post.
  after_save :touch_cache
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

  # Remove the temporary image created when we
  after_create :remove_url_tmp_image, if: :loading_from_url?
  def loading_from_url?
    !self.processed_from_url.nil?
  end
  def remove_url_tmp_image
    if File.exists?(self.processed_from_url)
      FileUtils.rm_f(self.processed_from_url)
    end
  end

  after_create :remove_real_tmp_image, unless: :loading_from_url?
  def remove_real_tmp_image
    filename = self.image.instance['image_file_name']
    dir = 'public/system/tmp/'

    if File.exists?(dir + filename)
      FileUtils.rm(dir + filename)
    end
  end

  after_save :reprocess_image, :if => :reprocessing?
  def reprocessing?
    if self.reprocessed.nil?
      !self.crop_x.blank? && !self.crop_y.blank? && !self.crop_w.blank? && !self.crop_h.blank?
    end
  end

  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.path(style))
  end

  private

  def reprocess_image
    image.reprocess!
  end
end
