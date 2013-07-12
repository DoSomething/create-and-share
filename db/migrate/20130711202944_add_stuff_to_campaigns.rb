class AddStuffToCampaigns < ActiveRecord::Migration
  def up
  	add_column :campaigns, :description, :text
  	add_column :campaigns, :image, :string
  end
end
