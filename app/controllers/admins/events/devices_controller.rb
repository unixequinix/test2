class Admins::Events::DevicesController < Admins::Events::BaseController
  # rubocop:disable all
  def index
    authorize Device.new
    @assets = {}
    @device_transactions = @current_event.device_transactions.order(:device_created_at)
    @devices = Device.where()

    transaction_counts = @current_event.transactions.onsite.group(:device_uid).count
    @devices = Device.where(mac: transaction_counts.keys)

    transaction_counts.each do |uid, count|
      device_transactions = @device_transactions.select { |t| t.device_uid.eql?(uid) }
      init = device_transactions.select { |t| t.action.eql?("device_initialization") }
      pack = device_transactions.select { |t| t.action.eql?("pack_device") }

      if (init.count - pack.count == 1) && (init.last&.device_created_at.to_s > pack.last&.device_created_at.to_s)
        status = "in_use"
        device_trans = (pack.map(&:number_of_transactions).sum - init[0..-2].map(&:number_of_transactions).sum) + init.count

      elsif (init.count == pack.count) && (pack.last&.device_created_at.to_s > init.last&.device_created_at.to_s)
        device_trans = (pack.map(&:number_of_transactions).sum - init.map(&:number_of_transactions).sum) + init.count
        status = (device_trans == pack.last&.number_of_transactions) ? "packed" : "wrong_transactions"

      else
        status = "to_check"
        device_trans = device_transactions.count
      end
      @assets[uid] = @assets[uid] || {}
      @assets[uid].merge!(device_transactions: device_trans,
                          server_transactions: count,
                          action: device_transactions.last&.action,
                          last_device_transaction: device_transactions.last&.number_of_transactions,
                          status: status,
                          asset_tracker: @devices.find { |d| d.mac.eql?(uid) }.asset_tracker)
    end
    @assets = @assets.group_by { |a| a.last[:status] }
  end

  def show

  end
end
