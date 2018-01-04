class AddInitializationTypeToDeviceRegistrations < ActiveRecord::Migration[5.1]
  def change
    add_column :device_registrations, :initialization_type, :string
  end
end
