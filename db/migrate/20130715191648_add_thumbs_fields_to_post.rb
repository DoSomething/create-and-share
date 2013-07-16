class AddThumbsFieldsToPost < ActiveRecord::Migration
  def change
    add_column :posts, :thumbs_up_count, :integer
    add_column :posts, :thumbs_down_count, :integer
  end
end
