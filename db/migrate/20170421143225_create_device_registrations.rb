class CreateDeviceRegistrations < ActiveRecord::Migration[5.0]
  def change
    create_table :device_registrations do |t|
      t.references :device, index: true, foreign_key: true
      t.references :event, index: true, foreign_key: true
      t.boolean :allowed, default: true
    end
  end
end
