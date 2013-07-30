class AddMemeHeaderToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :meme_header, :string
  end
end
