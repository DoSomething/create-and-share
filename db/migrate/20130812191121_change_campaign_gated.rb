class ChangeCampaignGated < ActiveRecord::Migration
  def up
    change_column :campaigns, :gated, :string, null: false
  end

  def down
  end
end
