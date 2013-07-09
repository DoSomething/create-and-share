class Share < ActiveRecord::Base
  attr_accessible :post_id, :uid
  belongs_to :post
end
