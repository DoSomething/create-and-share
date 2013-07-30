class Campaign < ActiveRecord::Base
  attr_accessible :developers, :end_date, :lead,
  :lead_email, :path, :start_date,
  :title, :gated, :description,
  :image, :mailchimp, :mobile_commons,
  :email_signup, :email_submit, :meme_header, :meme

  has_many :posts

  has_many :users, through: :participations
  has_many :participations, dependent: :destroy

  validates_presence_of :developers, :end_date, :lead,
  :lead_email, :path, :start_date,
  :title, :description,
  :image, :mailchimp, :mobile_commons,
  :email_signup, :email_submit

  validates :path, uniqueness: { case_sensitive: false }

  has_attached_file :image, :styles => { :campaign => '250x141!' }, :default_url => '/images/:style/default.png'
  validates_attachment :image, :presence => true, :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  before_save do
    if !self.meme
      self.meme_header = ""
    end
  end

  def gated?
    self.gated == true
  end
end
