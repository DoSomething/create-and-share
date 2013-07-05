class CreateCampaigns < ActiveRecord::Migration
  def change
    create_table :campaigns do |t|
      t.string :title
      t.datetime :start_date
      t.datetime :end_date
      t.string :path
      t.string :lead
      t.string :lead_email
      t.string :developers

      t.timestamps
    end
  end
end
