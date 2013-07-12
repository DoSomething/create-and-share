class RemoveColumnsFromPost < ActiveRecord::Migration
  def up
    remove_column :posts, :shelter
    remove_column :posts, :animal_type
  end

  def down
    add_column :posts, :animal_type, :string
    add_column :posts, :shelter, :string
  end
end
