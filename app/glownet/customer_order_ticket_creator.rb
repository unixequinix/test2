class CustomerOrderTicketCreator
  def save(ticket)
    if ticket.credential_type_item.catalogable_type == "Pack"
      ticket.pack_catalog_items_included.each do |pack_catalog_item|
        create_customer_order_for_pack(ticket, pack_catalog_item)
      end
    else
      create_customer_order_for_single_credits(ticket)
    end
  end

  private

  def create_customer_order_for_pack(ticket, pack_catalog_item)
    CustomerOrder.create(
      profile: ticket.profile,
      amount: pack_catalog_item.amount,
      catalog_item_id: pack_catalog_item.catalog_item_id,
      origin: CustomerOrder::TICKET_ASSIGNMENT,
      redeemed: false
    )
  end

  def create_customer_order_for_single_credits(ticket)
    CustomerOrder.create(
      profile: ticket.profile,
      amount: 1,
      catalog_item_id: ticket.credential_type_item.id,
      origin: CustomerOrder::TICKET_ASSIGNMENT,
      redeemed: false
    )
  end
end
