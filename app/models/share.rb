class Share < ActiveRecord::Base
  attr_accessible :post_id, :uid
  belongs_to :post
  belongs_to :user

  validates :post_id, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }
  validates :uid, :presence => true, :numericality => { :greater_than_or_equal_to => 0 }

  def self.total(model, id)
    if model == :post
      self.where(:post_id => id).count
    elsif model == :user
      self.where(:uid => id).count
    end
  end
end
