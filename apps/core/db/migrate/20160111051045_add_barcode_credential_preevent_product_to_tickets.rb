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

  class OrderItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :online_product
    belongs_to :preevent_product
  end

  def change
    add_column :tickets, :credential_redeemed, :boolean, null: false, default: false
    add_column :tickets, :company_ticket_type_id, :integer
    rename_column :tickets, :number, :code
    rename_column :tickets, :purchaser_name, :purchaser_first_name
    rename_column :tickets, :purchaser_surname, :purchaser_last_name

    migrate_ticket_types

    # TODO: Impossible without default company id for deleted items(paranoid)
    #  change_column :tickets, :company_ticket_type_id, :integer, null: false
  end

  def migrate_ticket_types
    TicketType.all.each do |ticket_type|
      preevent_items_ids = PreeventItem.where(purchasable_type: "Credit", event_id: 1).pluck(:id)
      credits_ids = PreeventItem.where(purchasable_type: "Credit",
                                       event_id: 1).pluck(:purchasable_id)

      entitlements_names_list = ticket_type.entitlements.pluck(:name)
      credential_types_ids = PreeventItem.where(name: entitlements_names_list,
                                                purchasable_type: "CredentialType",
                                                event_id: ticket_type.event_id).pluck(:id)
      order_items = OrderItem.joins(:online_product).where(online_products: { purchasable_id: credits_ids })

      preevent_product = build_preevent_product(ticket_type, credential_types_ids, preevent_items_ids, order_items)
      attach_purchase_parameters(order_items, preevent_product)
      preevent_product.save

      company = Company.find_or_create_by(name: ticket_type.company, event_id: ticket_type.event_id)
      company_ticket_type = create_company_ticket_type(ticket_type, company, preevent_product)
      update_company_ticket_type_in_tickets(ticket_type, company_ticket_type)
    end
    puts "TicketTypes Migrated √"
  end

  private

  def build_preevent_product(ticket_type, credential_types_ids, preevent_items_ids, order_items)
    amount = 1
    preevent_items_array = (credential_types_ids + preevent_items_ids).map do |preevent_item_id|
      amount = ticket_type.credit if PreeventItem.find(preevent_item_id).purchasable_type == "Credit"
      { preevent_item_id: preevent_item_id, amount: amount }
    end
    PreeventProduct.new(
      name: ticket_type.name,
      preevent_product_items_attributes: preevent_items_array,
      order_item_ids: order_items.pluck(:id),
      event_id: ticket_type.event_id,
      initial_amount: 1,
      step: 1,
      max_purchasable: 100,
      min_purchasable: 1,
      price: 1
    )
  end

  def attach_purchase_parameters(order_items, preevent_product)
    return unless order_items.first
    preevent_product.update_attributes(
      initial_amount: order_items.first.online_product.initial_amount,
      step: order_items.first.online_product.step,
      max_purchasable: order_items.first.online_product.max_purchasable,
      min_purchasable: order_items.first.online_product.min_purchasable,
      price: order_items.first.online_product.price
    )
  end

  def update_company_ticket_type_in_tickets(ticket_type, company_ticket_type)
    ticket_type.tickets.each do |ticket|
      ticket.update_attribute(:company_ticket_type, company_ticket_type)
    end
  end

  def create_company_ticket_type(ticket_type, company, preevent_product)
    CompanyTicketType.create(
      name: ticket_type.simplified_name || ticket_type.name,
      company: company,
      preevent_product: preevent_product,
      event_id: ticket_type.event_id)
  end
end
