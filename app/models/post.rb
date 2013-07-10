class Post < ActiveRecord::Base
  attr_accessible :uid, :adopted, :creation_time,
  	:flagged, :image, :name, :promoted,
  	:share_count, :shelter, :state, :city,
  	:story, :animal_type, :update_time,
    :meme_text, :meme_position,
    :crop_x, :crop_y, :crop_w, :crop_h, :crop_dim_w

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h, :cropped, :crop_dim_w

  validates :name,    :presence => true
  validates :shelter, :presence => true
  validates :animal_type,    :presence => true
  validates :city,    :presence => true
  validates :state,   :presence => true,
                      :length => { :maximum => 2 }
  validates :shelter, :presence => true

  has_attached_file :image, :styles => { :gallery => '450x450!' }, :default_url => '/images/:style/default.png', :processors => [:cropper]
  validates_attachment :image, :presence => true, :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  has_many :shares

  # The number of elements to show per "page" in the infinite scroll.
  def self.per_page
    10
  end

  # Removes HTML tags.  This technically will automatically be sanitized,
  # but better safe than sorry.
  before_save :strip_tags
  def strip_tags
    self.name = self.name.gsub(/\<[^\>]+\>/, '')
    self.shelter = self.shelter.gsub(/\<[^\>]+\>/, '')

    if !self.meme_text.nil?
      self.meme_text = self.meme_text.gsub(/\<[^\>]+\>/, '')
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

  # Clears cache after a new post.
  after_save :touch_cache, :update_img

  def touch_cache
    # We need to clear all caches -- Every cache depends on the one before it.
    Rails.cache.clear
  end

  # Writes text to image.
  def update_img
    @post = Post.find(self.id)
    image = @post.image.url(:gallery)
    image = '/public' + image.gsub(/\?.*/, '')

    if !@post.meme_text.nil?
      if File.exists? Rails.root.to_s + image
        PostsHelper.image_writer(image, @post.meme_text, @post.meme_position)
      end
    end
  end

  after_create :remove_tmp_image, :send_thx_email
  # Remove the temp uploaded image after a post is successfully created.
  def remove_tmp_image
    filename = self.image.instance['image_file_name']
    dir = 'public/system/tmp/'

    if File.exists?(dir + filename)
      FileUtils.rm(dir + filename)
    end
  end

  # Sends the "thanks for reporting back" email.
  def send_thx_email
    @user = User.where(:uid => self.uid).first
    if !@user.nil? && !@user.email.nil?
      Services::Mandrill.mail(@user.email, 'PicsforPets_2013_Reportback', 'How to get puppies adopted')
    end
  end   

  after_save :reprocess_image, :if => :cropping?
  def cropping?
    if self.cropped.nil?
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
