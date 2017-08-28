class AddSerialNumberToDevices < ActiveRecord::Migration[5.1]
  def change
    add_column :devices, :serial, :string
  end
end
