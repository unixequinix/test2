class RemoveDeviceReports < ActiveRecord::Migration[5.0]
  def change
    DeviceTransaction.where(action: ["device_report", "DEVICE_REPORT"]).destroy_all
  end
end
