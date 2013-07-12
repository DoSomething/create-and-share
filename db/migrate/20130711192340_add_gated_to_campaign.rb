class AddGatedToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :gated, :boolean
  end
end
