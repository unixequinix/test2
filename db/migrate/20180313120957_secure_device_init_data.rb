class SecureDeviceInitData < ActiveRecord::Migration[5.1]
  def change
    Device.all.each { |d| d.update! app_id: SecureRandom.hex(32).upcase }
    change_column_null :devices, :app_id, false
  end
end
