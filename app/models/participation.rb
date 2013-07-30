class Participation < ActiveRecord::Base
  attr_accessible :campaign_id, :intent, :user_id

  belongs_to :user
  belongs_to :campaign

  validates_presence_of :campaign_id, :user_id
end
