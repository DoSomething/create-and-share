class AddPagedFormToCampaign < ActiveRecord::Migration
  def change
    add_column :campaigns, :paged_form, :boolean
  end
end
