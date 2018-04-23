class TicketingIntegrationEventbrite < TicketingIntegration
  enum status: { unauthorized: 0, active: 1, inactive: 2 }

  belongs_to :event, inverse_of: :eventbrite_ticketing_integrations

  def self.policy_class
    TicketingIntegrationPolicy
  end

  def import
    first_call = Eventbrite::Order.all({ event_id: integration_event_id, page: 1, expand: "attendees" }, token)

    pages = first_call.pagination.page_count
    (1..pages).to_a.each do |page_number|
      orders = Eventbrite::Order.all({ event_id: integration_event_id, page: page_number, expand: "attendees" }, token).orders
      orders.each { |order| Ticketing::EventbriteImporter.perform_later(order.to_json, self) }
    end
  end
end
