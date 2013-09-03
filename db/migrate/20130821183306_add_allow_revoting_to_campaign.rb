class AddAllowRevotingToCampaign < ActiveRecord::Migration
  def up
    add_column :campaigns, :allow_revoting, :boolean, :default => false
  end
  def down
    remove_column :campaigns, :allow_revoting
  end
end
