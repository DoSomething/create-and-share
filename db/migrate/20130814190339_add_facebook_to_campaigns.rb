class AddFacebookToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :facebook, :string
  end
end
