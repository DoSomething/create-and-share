class School < ActiveRecord::Base
  attr_accessible :city, :gsid, :state, :title, :zip
  has_many :posts

  validates :city, presence: true,
                   format: { with: /[a-z0-9\-\_\s\'\"]+/i }
  validates :gsid, presence: true,
                   numericality: true,
                   uniqueness: true
  validates :state, presence: true,
                    format: { with: /[A-Z]{2}/ }
  validates :title, presence: true
  validates :zip, presence: true,
                  format: { with: /[A-Z0-9\-\_\s]+/ }
end
