class Admins::Events::DevicesController < Admins::Events::BaseController
  def index
    @devices = @current_event.device_transactions.order(device_created_at: :asc).group_by(&:device_uid)
    authorize Device.all
    @assets = {}
    Device.where(mac: @devices.map { |mac, _| mac }).each { |d| @assets[d.mac] = d.asset_tracker }
  end
end
