class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.integer :event_id, null: false
      t.string :name, null: false
      t.timestamps null: false
    end
  end
end
