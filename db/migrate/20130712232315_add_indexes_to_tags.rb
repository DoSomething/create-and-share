class AddIndexesToTags < ActiveRecord::Migration
  def up
    add_index :tags, :campaign_id
    add_index :tags, :post_id
  end
  def down
    remove_index :tags, :campaign_id
    remove_index :tags, :post_id
  end
end
