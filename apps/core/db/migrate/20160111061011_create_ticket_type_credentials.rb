class CreateTicketTypeCredentials < ActiveRecord::Migration
  def change
    create_table :ticket_type_credentials do |t|
      t.integer :companies_ticket_type_id
      t.integer :preevent_product_id

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end

    migrate_ticket_types
  end

  def migrate_ticket_types
    TicketType.all.each do |ticket_type|
      credit = PreeventItem.where(purchasable_type: "Credit", event_id: ticket_type.event_id).pluck(:id)
      entitlements_names_list = ticket_type.entitlements.pluck(:name)
      credential_types_ids = PreeventItem.where(
        name: entitlements_names_list,
        purchasable_type: "CredentialType",
        event_id: ticket_type.event_id
      ).pluck(:id)

      preevent_product = PreeventProduct.create(
        name: ticket_type.name,
        preevent_item_ids: credential_types_ids + credit,
        preevent_product_items_attributes: [{amount: ticket_type.credit || 0}],
        event_id: ticket_type.event_id
      )

      companies_ticket_types = CompaniesTicketType.create(
        name: ticket_type.simplified_name || ticket_type.name,
        company: ticket_type.company,
        preevent_products: [preevent_product],
        event_id: ticket_type.event_id
      )

      ticket_type.tickets.each do |ticket|
        ticket.update_attribute(:preevent_product_id, preevent_product.id)
      end
    end
  end
end