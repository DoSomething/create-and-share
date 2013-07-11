class Campaign < ActiveRecord::Base
  attr_accessible :developers, :end_date, :lead, :lead_email, :path, :start_date, :title, :gated
  has_many :posts

  def gated?
    self.gated == true
  end
end
