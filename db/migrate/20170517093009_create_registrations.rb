class CreateRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :event_registrations do |t|
      t.integer :role
      t.boolean :accepted, default: false
      t.string :email
      t.references :event, index: true
      t.references :user, index: true
      t.index [:event_id, :user_id], unique: true
    end
  end
end
