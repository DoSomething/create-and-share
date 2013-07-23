class RemoveRedundantTextFromPosts < ActiveRecord::Migration
  def up
    remove_column :posts, :bottom_text
    remove_column :posts, :top_text
  end

  def down
    add_column :posts, :top_text, :string
    add_column :posts, :bottom_text, :string
  end
end
