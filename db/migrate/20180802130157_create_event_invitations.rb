class CreateEventInvitations < ActiveRecord::Migration[5.1]
  def change
    create_table :event_invitations do |t|
      t.integer :role
      t.string :email, null: false
      t.integer :event_id, null: false
      t.boolean :accepted, default: false
      t.timestamps
    end
  end
end
