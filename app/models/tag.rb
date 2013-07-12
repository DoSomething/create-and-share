class Tag < ActiveRecord::Base
  attr_accessible :campaign_id, :column, :post_id, :value

  def self.create_tags(record)
    Tag.where(:post_id => record.id).delete_all

    tags = []
    record.extras.each do |key, value|
      addition = { :campaign_id => record.campaign_id, :post_id => record.id, :column => key, :value => value }
      tags << addition
    end

    Tag.create(tags)
  end
end
