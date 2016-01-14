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
      entitlements_names = ticket_type.entitlements.pluck(:name)
      credential_types_ids = PreeventItem.where(
        name: entitlements_names,
        purchasable_type: "CredentialType",
        event_id: ticket_type.event_id
      ).pluck(:id)

      pp_credit = PreeventProduct.create(
        name: ticket_type.simplified_name || ticket_type.company,
        preevent_item_ids: credential_types_ids + credit,
        preevent_product_items_attributes: [{amount: ticket_type.credit || 0}],
        event_id: ticket_type.event_id
      )
    end
  end
end