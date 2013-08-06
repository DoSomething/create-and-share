class RemoveFieldsFromPosts < ActiveRecord::Migration
  def up
    remove_column :posts, :thumbs_up_count
    remove_column :posts, :thumbs_down_count
  end

  def down
    add_column :posts, :thumbs_down_count, :integer
    add_column :posts, :thumbs_up_count, :integer
  end
end
