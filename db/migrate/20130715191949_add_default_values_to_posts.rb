class AddDefaultValuesToPosts < ActiveRecord::Migration
  def change
  	change_column :posts, :thumbs_up_count, :integer, :default => 0
  	change_column :posts, :thumbs_down_count, :integer, :default => 0
  end
end
