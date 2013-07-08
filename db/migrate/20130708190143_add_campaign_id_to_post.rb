class AddCampaignIdToPost < ActiveRecord::Migration
  def up
  	add_column :posts, :campaign_id, :integer
  end
end
