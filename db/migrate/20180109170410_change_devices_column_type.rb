class ChangeDevicesColumnType < ActiveRecord::Migration[5.1]
  def change
    change_column :devices, :mac, :citext, from: :string
  end
end
