class Admins::Events::AssetTrackersController < Admins::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize
    devices = current_event.device_transactions.select(:device_uid).uniq
    asset_trackers = Device.all.select(:mac, :asset_tracker).group_by(&:mac)
    transactions = Device.transactions_count(current_event)
    @devices = { wrong_transactions: [], not_packed: [], packed: [] }

    devices.each do |d_tr|
      hash = { device_uid: d_tr.device_uid }
      hash[:asset_tracker] = asset_trackers[d_tr.device_uid]&.first&.asset_tracker
      transaction = transactions.find { |t| t["device_uid"] == d_tr.device_uid }
      hash[:device_db_index] = d_tr.device_db_index
      hash[:transactions_count] = transaction["transactions_count"]
      hash[:device_counter] = transaction["device_counter"]
      hash[:transaction_type] = transaction["transaction_type"].humanize

      @colors = { wrong_transactions: "#E53A40", not_packed: "#fc913a", packed: "#56A902" }
      @devices[:not_packed] << hash && next if transaction["transaction_type"] != "pack_device"
      @devices[:wrong_transactions] << hash && next if hash[:device_counter] != hash[:transactions_count]
      @devices[:packed] << hash
    end
  end
end
