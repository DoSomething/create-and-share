class CreateSchools < ActiveRecord::Migration
  def change
    create_table :schools do |t|
      t.integer :gsid
      t.string :title
      t.string :state
      t.string :city
      t.string :zip

      t.timestamps
    end
  end
end
