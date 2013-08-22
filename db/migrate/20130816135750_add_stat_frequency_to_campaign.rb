class AddStatFrequencyToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :stat_frequency, :integer
  end
end
