class Admins::Events::DevicesController < Admins::Events::BaseController
  # rubocop:disable all
  def index
    authorize Device.new
    devices = @current_event.device_transactions.order(device_created_at: :asc).group_by(&:device_uid)
    @assets = {}
    Device.where(mac: devices.map { |mac, _| mac }).each { |d| @assets[d.mac] = { asset_tracker: d.asset_tracker } }
    transactions_sql = Device.transactions_count(@current_event)

    devices.map do |device, transactions|
      init = transactions.select { |t| t.action == "device_initialization" }
      pack = transactions.select { |t| t.action == "pack_device" }
      server_trans = transactions_sql.find { |t| t["device_uid"] == device }

      if (init.count - pack.count == 1) && (init.last&.device_created_at.to_s > pack.last&.device_created_at.to_s)
        status = "in_use"
        device_trans = (pack.map(&:number_of_transactions).sum - init[0..-2].map(&:number_of_transactions).sum) + init.count

      elsif (init.count == pack.count) && (pack.last&.device_created_at.to_s > init.last&.device_created_at.to_s)
        device_trans = (pack.map(&:number_of_transactions).sum - init.map(&:number_of_transactions).sum) + init.count
        status = (device_trans == server_trans["transactions_count"]) ? "packed" : "wrong_transactions"
      else
        status = "to_check"
      end
      @assets[device] = @assets[device] || {}
      @assets[device].merge!(device_transactions: device_trans,
                             server_transactions: server_trans["transactions_count"],
                             action: server_trans["action"],
                             last_device_transaction: transactions.last[:number_of_transactions],
                             status: status)
    end
    @assets = @assets.group_by { |a| a.last[:status] }
  end
end
