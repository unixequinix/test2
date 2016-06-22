class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    @devices = current_event.device_transactions.order(device_created_at: :asc).group_by(&:device_uid)
    t_classes = [DeviceTransaction, CreditTransaction, BanTransaction, CredentialTransaction,
                 MoneyTransaction, AccessTransaction, OrderTransaction]
    event = Event.find(2)

    @last_transactions = {}
    DeviceTransaction.select(:device_uid, :event_id, :transaction_type, :number_of_transactions, :device_created_at)
         .where(event: event)
         .order('device_created_at DESC')
         .group_by(&:device_uid)
         .each do |mac, tr|
      @last_transactions[mac] = { transaction_type: tr.first.transaction_type,
                                  counter: tr.first.number_of_transactions }
    end

    @counter = {}
    t_classes.each do |klass|
      klass.select(:device_uid, :device_db_index, :event_id)
           .where(event: event)
           .group_by(&:device_uid)
           .each do |mac, trs|
        prev = @counter[mac].nil? ? 0 : @counter[mac]

        @counter[mac] = prev + trs.size
      end
    end

    @assets = {}
    Device.where(mac: @devices.map{|mac, _| mac }).each { |d| @assets[d.mac] = d.asset_tracker }
  end
end
