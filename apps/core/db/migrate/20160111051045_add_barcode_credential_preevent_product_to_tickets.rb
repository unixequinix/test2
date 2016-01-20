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

    migrate_ticket_types
  end

  def migrate_ticket_types
    TicketType.all.each do |ticket_type|

      preevent_items_ids = PreeventItem.where(purchasable_type: 'Credit',
                                       event_id: 1).pluck(:id)
      credits_ids = PreeventItem.where(purchasable_type: 'Credit',
                                       event_id: 1).pluck(:purchasable_id)

      entitlements_names_list = ticket_type.entitlements.pluck(:name)
      credential_types_ids = PreeventItem.where(name: entitlements_names_list,
                                                purchasable_type: 'CredentialType',
                                                event_id: ticket_type.event_id).pluck(:id)
      order_items = OrderItem.joins(:online_product).where(online_products: {purchasable_id: credits_ids})
      preevent_product = PreeventProduct.new(
        name: ticket_type.name,
        preevent_item_ids: credential_types_ids + preevent_items_ids,
        preevent_product_items_attributes: [{ amount: ticket_type.credit || 1 }],
        order_item_ids: order_items.pluck(:id),
        event_id: ticket_type.event_id
      )

      if(order_items.first)
        preevent_product.initial_amount =  order_items.first.online_product.initial_amount || 1
        preevent_product.step =  order_items.first.online_product.step || 1
        preevent_product.max_purchasable =  order_items.first.online_product.max_purchasable || 100
        preevent_product.min_purchasable =  order_items.first.online_product.min_purchasable || 1
      else
        preevent_product.initial_amount = 1
        preevent_product.step = 1
        preevent_product.max_purchasable = 100
        preevent_product.min_purchasable = 1
      end

      preevent_product.save

      company = Company.find_or_create_by(name: ticket_type.company, event_id: ticket_type.event_id)
      company_ticket_type = CompanyTicketType.new(
        name: ticket_type.simplified_name || ticket_type.name,
        company: company,
        preevent_product: preevent_product,
        event_id: ticket_type.event_id)

      ticket_type.tickets do |ticket|
        ticket.update_attributes(company_ticket_type: company_ticket_type)
      end
    end
    puts 'TicketTypes Migrated √'
  end
end
