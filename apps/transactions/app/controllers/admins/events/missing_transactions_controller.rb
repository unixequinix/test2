class Admins::Events::MissingTransactionsController < Admins::Events::BaseController
  def index
    @devices = current_event.device_transactions.order(device_created_at: :asc).group_by(&:device_uid)

    t_classes = [CreditTransaction, BanTransaction, CredentialTransaction, MoneyTransaction, AccessTransaction, OrderTransaction]
    @counters = {}
    event = Event.find 2
    t_classes.each do |klass|
      klass.select(:device_uid, :device_db_index, :event_id)
           .where(event: event)
           .group_by(&:device_uid)
           .each do |mac, trs|
        prev = @counters[mac].nil? ? [] : @counters[mac]

        @counters[mac] = (prev + trs.map(&:device_db_index)).sort
      end
    end

    @missing_counters = @counters.map do |mac, cs|
      [mac, (1..cs.sort.last.to_i).to_a - cs]
    end.to_h

    @assets = {}
    Device.where(mac: @devices.map{|mac, _| mac }).each { |d| @assets[d.mac] = d.asset_tracker }
  end
end
