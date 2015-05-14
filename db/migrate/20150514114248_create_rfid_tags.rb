class CreateRfidTags < ActiveRecord::Migration
  def change
    create_table :rfid_tags do |t|
      t.string :tag_uid
      t.string :tag_serial_number

      t.timestamps null: false
    end
  end
end
