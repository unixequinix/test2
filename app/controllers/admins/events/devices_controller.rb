class Admins::Events::DevicesController < Admins::Events::BaseController
  # rubocop:disable all
  def index
    pack_names = %w(pack_device lock_device)
    authorize Device.new
    @assets = {}
    @current_event.device_transactions.where(status_code: 0).group_by(&:device_uid).each do |uid, device_transactions|

      count = @current_event.transactions.onsite.where(device_uid: uid).count
      last_onsite = @current_event.transactions.onsite.where(device_uid: uid).order(:device_created_at).last
      last = device_transactions.sort_by(&:device_created_at).last
      pack_transactions = device_transactions.select {|t| t.action.in?(pack_names) }.map { |t| t.number_of_transactions - t.device_db_index }.sum
      init_transactions = device_transactions.select {|t| t.action.in?(["device_initialization"]) }.map { |t| t.number_of_transactions - t.device_db_index }.sum

      device_trans = pack_transactions - init_transactions
      case
        when last.action.eql?("device_initialization") then status = "live"
        when last.action.in?(pack_names) && (device_trans == count) then status = "locked"
        when (last.number_of_transactions - last.device_db_index == count) && device_transactions.map(&:device_db_index).count(1).eql?(1) then status = "locked"
        when last.action.in?(pack_names) && (device_trans != count) then status = "to_check"
        else status = "to_check"
      end

      @assets[uid] = @assets[uid].to_h
      device = Device.find_by(mac: uid)
      count_diff = device_trans - count
      msg = count_diff.positive? ? "Device has #{count_diff.abs} transactions too many" : "Server has #{count_diff.abs} transactions too many"
      msg = "Good to go!" if count_diff.zero?
      @assets[uid].merge!(msg: msg,
                          count_diff: count_diff,
                          action: last&.action,
                          status: status,
                          asset_tracker: device&.asset_tracker,
                          device_id: device&.id,
                          station: last_onsite&.station&.name,
                          last_time_used: last_onsite&.device_created_at)
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
