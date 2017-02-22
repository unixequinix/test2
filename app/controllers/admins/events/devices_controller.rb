class Admins::Events::DevicesController < Admins::Events::BaseController
  # rubocop:disable all
  def index
    authorize Device.new
    @assets = {}
    @current_event.device_transactions.where(status_code: 0).group_by(&:device_uid).each do |uid, device_transactions|

      count = @current_event.transactions.onsite.where(device_uid: uid).count
      last = device_transactions.sort_by(&:device_db_index).last
      pack_transactions = device_transactions.select {|t| t.action.in?(["pack_device", "lock_device"]) }.map { |t| t.number_of_transactions - t.device_db_index }.sum
      init_transactions = device_transactions.select {|t| t.action.in?(["device_initialization"]) }.map { |t| t.number_of_transactions - t.device_db_index }.sum

      device_trans = pack_transactions - init_transactions

      case
        when last.action.eql?("device_initialization") then status = "in_use"
        when last.action.in?(["lock_device", "pack_device"]) && (device_trans == count) then status = "packed"
        when last.action.in?(["lock_device", "pack_device"]) && (device_trans != count) then status = "wrong_transactions"
        else status = "to_check"
      end

      @assets[uid] = @assets[uid].to_h
      device = Device.find_by(mac: uid)
      @assets[uid].merge!(server_transactions: count, action: last&.action, last_device_transaction: device_trans, status: status, asset_tracker: device&.asset_tracker, device_id: device&.id)
    end
    @assets = @assets.group_by { |a| a.last[:status] }
  end

  def show
    @device = Device.find(params[:id])
    authorize(@device)
    @transactions = @current_event.transactions.where(device_uid: @device.mac)
    @device_transactions = @current_event.device_transactions.where(device_uid: @device.mac).order(:device_created_at)
  end
end
