class AddUniquenessToDevices < ActiveRecord::Migration
  def change
    add_index :devices, [:mac, :imei, :serial_number], unique: true
  end
end
