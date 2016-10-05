class Admins::Events::AssetTrackersController < Admins::Events::BaseController
  # rubocop:disable Metrics/PerceivedComplexity, Metrics/AbcSize, Metrics/MethodLength
  def index
    devices = current_event.device_transactions.status_ok.order(device_created_at: :asc).group_by(&:device_uid)
    @assets = {}
    Device.where(mac: devices.map { |mac, _| mac }).each { |d| @assets[d.mac] = { asset_tracker: d.asset_tracker } }
    transactions_sql = Device.transactions_count(current_event)

    devices.map do |device, transactions|
      init = transactions.select { |t| t.transaction_type == "device_initialization" }
      pack = transactions.select { |t| t.transaction_type == "pack_device" }
      server_trans = transactions_sql.find { |t| t["device_uid"] == device }

      if (init.count - pack.count == 1) && (init.last&.device_created_at.to_s > pack.last&.device_created_at.to_s)
        status = "in_use"
        device_trans = (pack.map(&:number_of_transactions).sum - init[0..-2].map(&:number_of_transactions).sum) + init.count # rubocop:disable Metrics/LineLength

      elsif (init.count == pack.count) && (pack.last&.device_created_at.to_s > init.last&.device_created_at.to_s)
        device_trans = (pack.map(&:number_of_transactions).sum - init.map(&:number_of_transactions).sum) + init.count
        status = if device_trans == server_trans["transactions_count"]
                   "packed"
                 else
                   "wrong_transactions"
                 end

      else
        status = "to_check"
      end
      @assets[device].merge!(device_transactions: device_trans,
                             server_transactions: server_trans["transactions_count"],
                             transaction_type: server_trans["transaction_type"],
                             last_device_transaction: transactions.last[:number_of_transactions],
                             status: status)
    end
    @assets = @assets.group_by { |a| a.last[:status] }
  end
end
