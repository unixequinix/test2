class AddBarcodeCredentialPreeventProductToTickets < ActiveRecord::Migration
  class TicketType < ActiveRecord::Base
    belongs_to :event
    has_many :tickets, dependent: :restrict_with_error
    has_many :entitlement_ticket_types, dependent: :destroy
    has_many :entitlements, through: :entitlement_ticket_types
  end

  class EntitlementTicketType < ActiveRecord::Base
    belongs_to :entitlement
    belongs_to :ticket_type
  end

  class Entitlement < ActiveRecord::Base
  end

  class Credit < ActiveRecord::Base
     has_one :online_product, as: :purchasable, dependent: :destroy
  end

  class OnlineProduct < ActiveRecord::Base
    belongs_to :event
    belongs_to :purchasable, polymorphic: true, touch: true
    has_many :order_items
  end

  def change
    add_column :tickets, :barcode, :string
    add_column :tickets, :credential_redeemed, :boolean, null: false, default: false
    add_column :tickets, :company_ticket_type_id, :integer

    migrate_ticket_types
  end

  def migrate_ticket_types
    TicketType.all.each do |ticket_type|
      credits_ids = PreeventItem.where(
        purchasable_type: "Credit",
        event_id: ticket_type.event_id
      ).pluck(:id)


      entitlements_names_list = ticket_type.entitlements.pluck(:name)
      credential_types_ids = PreeventItem.where(
        name: entitlements_names_list,
        purchasable_type: "CredentialType",
        event_id: ticket_type.event_id
      ).pluck(:id)

      order_items_ids = Credit.find(credits_ids).select{|o| o.online_product.id if o.online_product}
      preevent_product = PreeventProduct.create(
        name: ticket_type.name,
        preevent_item_ids: credential_types_ids + credits_ids,
        preevent_product_items_attributes: [{amount: ticket_type.credit || 0}],
        order_item_ids: order_items_ids,
        event_id: ticket_type.event_id
      )

      company = Company.find_or_create_by(name: ticket_type.company)
      company_ticket_type = CompanyTicketType.create(
        name: ticket_type.simplified_name || ticket_type.name,
        company: company,
        preevent_product: preevent_product,
        event_id: ticket_type.event_id
      )

      ticket_type.tickets.each do |ticket|
        ticket.update_attributes(company_ticket_type: company_ticket_type)
      end
    end
    puts "TicketTypes Migrated √"
  end
end

