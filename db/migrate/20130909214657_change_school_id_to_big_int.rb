class ChangeSchoolIdToBigInt < ActiveRecord::Migration
  def up
    change_column :posts, :school_id, :integer, :limit => 8
  end
end
