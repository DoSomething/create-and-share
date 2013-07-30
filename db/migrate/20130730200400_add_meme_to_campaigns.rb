class AddMemeToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :meme, :boolean
  end
end
