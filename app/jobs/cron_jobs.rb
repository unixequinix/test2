class CronJobs
  def self.try_to_open_refunds
    Event.launched.where(open_refunds: false).find_each do |event|
      date = event.refunds_start_date
      next unless date
      Time.use_zone(event.timezone) { event.update(open_refunds: true) if Time.current >= Time.zone.parse(date.to_formatted_s(:human)) }
    end
  end

  def self.try_to_end_refunds
    Event.launched.where(open_refunds: true).find_each do |event|
      date = event.refunds_end_date
      next unless date
      Time.use_zone(event.timezone) { event.update(open_refunds: false) if Time.current >= Time.zone.parse(date.to_formatted_s(:human)) }
    end
  end

  def self.import_tickets
    TicketingIntegration.active.map(&:import)
  end
end
