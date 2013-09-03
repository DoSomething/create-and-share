class RemoveIntentFromUsers < ActiveRecord::Migration
  def up
    remove_column :users, :intent
  end

  def down
    add_column :users, :intent, :boolean
  end
end
