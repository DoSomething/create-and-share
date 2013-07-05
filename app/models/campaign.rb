class Campaign < ActiveRecord::Base
  attr_accessible :developers, :end_date, :lead, :lead_email, :path, :start_date, :title
  has_many :posts
end
