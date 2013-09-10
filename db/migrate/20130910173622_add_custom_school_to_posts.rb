class AddCustomSchoolToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :custom_school, :string
  end
end
