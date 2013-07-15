class AddExtrasColumnToPost < ActiveRecord::Migration
  def change
    add_column :posts, :extras, :text
  end
end
