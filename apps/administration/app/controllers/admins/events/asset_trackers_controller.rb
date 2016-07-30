class Admins::Events::AssetTrackersController < Admins::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize
    devices = current_event.device_transactions.select(:device_uid).uniq
    asset_trackers = Device.all.select(:mac, :asset_tracker).group_by(&:mac)
    transactions = Device.transactions_count(current_event)
    @devices = classify_devices(devices, asset_trackers, transactions)
  end

  private

  def classify_devices(devices, asset_trackers, transactions)
    @colors = { wrong_transactions: "#E53A40", not_packed: "#fc913a", packed: "#56A902" }
    classified_devices = { wrong_transactions: [], not_packed: [], packed: [] }

    devices.each do |d_tr|
      device_info = { device_uid: d_tr.device_uid }
      device_info[:asset_tracker] = asset_trackers[d_tr.device_uid]&.first&.asset_tracker
      transaction = transactions.find { |t| t["device_uid"] == d_tr.device_uid }
      device_info[:transactions_count] = transaction["transactions_count"]
      device_info[:device_counter] = transaction["device_counter"]
      device_info[:transaction_type] = transaction["transaction_type"].humanize
      classified_devices[:not_packed] <<
        hash && next if transaction["transaction_type"] != "pack_device"
      classified_devices[:wrong_transactions] <<
        hash && next if wrong?(device_info[:device_counter], device_info[:transactions_count])
      classified_devices[:packed] << hash
    end
    classified_devices
  end

  def wrong?(device_counter, transaction_count)
    diff = device_counter - transaction_count
    diff > 5 || diff < -5
  end
end
