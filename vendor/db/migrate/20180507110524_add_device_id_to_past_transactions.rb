class AddDeviceIdToPastTransactions < ActiveRecord::Migration[5.1]
  def change
    scope = Transaction.where(device_id: nil)

    Device.all.group_by(&:mac).map { |key, devs| [key, devs.last.id] }.to_h.each do |mac, id|
      puts "--- updating mac #{mac}"
      scope.where(device_uid: [mac.downcase, mac.upcase]).update_all(device_id: id)
    end

    team = Team.find_or_initialize_by(name: "Glownet")
    team.save(validate: false)
    unknown_device = Device.find_or_create_by!(team: team, mac: "unknwon", asset_tracker: "unknown", app_id: "unknown")
    Transaction.where(device_id: nil).update_all(device_id: unknown_device.id, device_uid: "unknown")
    remove_index :transactions, name: "index_transactions_on_device_columns"
  end
end