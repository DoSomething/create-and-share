class Campaign < ActiveRecord::Base
  attr_accessible :developers, :end_date, :lead,
  :lead_email, :path, :start_date,
  :title, :gated, :description,
  :image, :mailchimp, :mobile_commons,
  :email_signup, :email_submit, :meme_header, :meme,
  :paged_form, :has_school_field, :facebook

  has_many :posts

  has_many :users, through: :participations
  has_many :participations, dependent: :destroy

  validates_presence_of :developers, :end_date, :lead,
  :lead_email, :path, :start_date,
  :title, :description,
  :image, :mailchimp, :mobile_commons,
  :email_signup, :email_submit

  validates :path, uniqueness: { case_sensitive: false }

  has_attached_file :image, :styles => { :campaign => '250x141!' }, :default_url => '/images/:style/default.png', :preserve_files => true
  validates_attachment :image, :presence => true, :content_type => { :content_type => ['image/jpeg', 'image/png', 'image/gif'] }

  before_save do
    if !self.meme || !self.meme_header
      self.meme_header = ""
    end
  end

  def gated? type
    self.gated == type
  end

  def is_gated? (params, session)
    is_on_login_page = (params[:controller] == 'sessions' && params[:action] == 'new')
    campaign_exists = !params[:campaign].nil?
    entire_campaign_is_gated = self.gated? 'all'
    on_submit_page = (params[:action] == 'new' && params[:controller] == 'posts')
    submit_page_is_gated = self.gated? 'submit'
    campaign_is_not_gated = self.gated? ''

    campaign_exists && ((entire_campaign_is_gated || (submit_page_is_gated && on_submit_page)) && !campaign_is_not_gated) || is_on_login_page
  end
end
