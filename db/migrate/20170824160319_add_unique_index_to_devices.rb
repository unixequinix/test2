class AddUniqueIndexToDevices < ActiveRecord::Migration[5.1]
  def change
    add_index :devices, :mac, unique: true
  end
end
