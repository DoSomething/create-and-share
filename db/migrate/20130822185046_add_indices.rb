class AddIndices < ActiveRecord::Migration
  def up
    add_index :posts, :state
    add_index :posts, :flagged
    add_index :posts, :name
    add_index :posts, :school_id
    add_index :posts, :uid
    add_index :shares, :uid
    add_index :tags, :column
    add_index :tags, :value
    add_index :users, :uid
    add_index :users, :fbid
  end

  def down
  end
end
