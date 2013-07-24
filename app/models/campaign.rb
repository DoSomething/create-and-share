class Campaign < ActiveRecord::Base
  attr_accessible :developers, :end_date, :lead,
  :lead_email, :path, :start_date,
  :title, :gated, :description,
  :image, :mailchimp, :mobile_commons,
  :email_signup, :email_submit, :meme_header

  has_many :posts

  validates_presence_of :developers, :end_date, :lead,
  :lead_email, :path, :start_date,
  :title, :description,
  :image, :mailchimp, :mobile_commons,
  :email_signup, :email_submit, :meme_header

  validates_uniqueness_of :path

  has_attached_file :image, :styles => { :campaign => '250x141!' }, :default_url => '/images/:style/default.png'
  validates_attachment :image, :presence => true, :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  def gated?
    self.gated == true
  end
end
