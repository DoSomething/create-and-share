class AddGsidIndexToSchool < ActiveRecord::Migration
  def change
  	add_index :schools, :gsid, unique: true
  end
end
