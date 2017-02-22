class AddIndexToDeviceTransactions < ActiveRecord::Migration[5.0]
  def change
    ts = DeviceTransaction.select(:device_created_at, :device_uid, :event_id).group(:device_created_at, :device_uid, :event_id).having("count(*) > 1").map(&:device_uid)
    DeviceTransaction.where(device_uid: ts).group_by { |t| [t.device_created_at, t.device_uid, t.event_id] }.each do |_, transactions|
      next if transactions.size == 1
      rest = transactions.drop(1)
      rest.map(&:delete)
    end

    add_index :device_transactions, [:device_created_at, :device_uid, :event_id], unique: true, name: "index_device_transactions_on_columns"
  end
end
