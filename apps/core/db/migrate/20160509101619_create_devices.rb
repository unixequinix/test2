class CreateDevices < ActiveRecord::Migration
  def change
    create_table :devices do |t|
      t.string :name
      t.string :imei
      t.string :mac
      t.string :serial_number

      t.timestamps null: false
    end
  end
end
