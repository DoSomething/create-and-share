class AddMcFieldsToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :mailchimp, :string
    add_column :campaigns, :mobile_commons, :string
  end
end
