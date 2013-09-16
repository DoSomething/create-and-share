class AddThumbsCountFieldsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :thumbs_up_count, :integer, default: 0
    add_column :posts, :thumbs_down_count, :integer, default: 0
  end
end
