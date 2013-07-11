class AddIndexes < ActiveRecord::Migration
  def up
  	add_index :posts, :campaign_id
  	add_index :shares, :post_id
  end

  def down
  end
end
