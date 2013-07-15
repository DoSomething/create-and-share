class AddMoreMailChimpToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :email_submit, :string
    add_column :campaigns, :email_signup, :string
  end
end
