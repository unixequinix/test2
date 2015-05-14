class CreateRfidTagRegistrations < ActiveRecord::Migration
  def change
    create_table :rfid_tag_registrations do |t|
      t.belongs_to :customer, null: false
      t.belongs_to :rfid_tag, null: false, index: true
      t.string :aasm_state

      t.timestamps null: false
    end
  end
end
