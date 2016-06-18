class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    @devices = current_event.device_transactions.order(device_created_at: :asc).group_by(&:device_uid).select do |_, ts|
      ts.last.transaction_type != "pack_device"
    end

    @assets = {}
    Device.where(mac: @devices.map{|uid, _| uid }).each { |d| @assets[d.mac] = d.asset_tracker }
  end
end
