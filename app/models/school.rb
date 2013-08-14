class School < ActiveRecord::Base
  attr_accessible :city, :gsid, :state, :title, :zip
  has_many :posts
end
