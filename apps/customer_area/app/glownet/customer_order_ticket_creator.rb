class CustomerOrderTicketCreator
  def save(ticket)
    ticket.pack_catalog_items_included.each do |pack_catalog_item|
      customer_order = CustomerOrder.create(
        customer_event_profile: ticket.assigned_ticket_credential.customer_event_profile,
        amount: pack_catalog_item.amount,
        catalog_item_id: pack_catalog_item.catalog_item_id,
        origin: CustomerOrder::TICKET_ASSIGNMENT
      )
      customer_order.credential_assignments << ticket.assigned_ticket_credential
      OnlineOrder.create(
        redeemed: false,
        customer_order: customer_order
      )
    end
  end

  def delete(ticket)
    ticket.assigned_ticket_credential.customer_orders.each(&:destroy)
  end
end
