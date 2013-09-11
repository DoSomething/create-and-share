class AddSignupTypeToUser < ActiveRecord::Migration
  def change
    add_column :users, :signup_type, :string
  end
end
