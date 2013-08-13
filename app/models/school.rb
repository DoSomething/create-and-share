class School < ActiveRecord::Base
  attr_accessible :city, :gsid, :state, :title, :zip
  belongs_to :post, foreign_key: :gsid
end
