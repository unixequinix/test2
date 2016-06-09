class CustomerOrderCreator
  def save(ticket)
    if ticket.credential_type_item.catalogable_type == "Pack"
      ticket.pack_catalog_items_included.each do |pack_catalog_item|
        create_customer_order_for_pack(ticket, pack_catalog_item)
      end
    else
      create_customer_order_for_single_credits(ticket)
    end
  end

  def delete(ticket)
    ticket.assigned_ticket_credential.customer_orders.each(&:destroy)
  end

  private

  def create_online_order(customer_order)
    OnlineOrder.create(redeemed: false, customer_order: customer_order)
  end

  def create_customer_order_for_pack(ticket, pack_catalog_item)
    customer_order = CustomerOrder.create(
      profile: ticket.assigned_ticket_credential(true).profile,
      amount: pack_catalog_item.amount,
      catalog_item_id: pack_catalog_item.catalog_item_id,
      origin: CustomerOrder::TICKET_ASSIGNMENT
    )
    customer_order.credential_assignments << ticket.assigned_ticket_credential
    create_online_order(customer_order)
  end

  def create_customer_order_for_single_credits(ticket)
    customer_order = CustomerOrder.create(
      profile: ticket.assigned_ticket_credential(true).profile,
      amount: 1,
      catalog_item_id: ticket.credential_type_item.id,
      origin: CustomerOrder::TICKET_ASSIGNMENT
    )
    customer_order.credential_assignments << ticket.assigned_ticket_credential
    create_online_order(customer_order)
  end
end
