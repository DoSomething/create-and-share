class CreateParticipations < ActiveRecord::Migration
  def change
    create_table :participations do |t|
      t.integer :user_id
      t.integer :campaign_id
      t.boolean :intent

      t.timestamps
    end
    add_index :participations, :user_id
    add_index :participations, :campaign_id
    add_index :participations, [:user_id, :campaign_id], unique: true
  end
end
