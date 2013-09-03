class AddHasSchoolFieldToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :has_school_field, :boolean
  end
end
