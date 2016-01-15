class AddPreeventProductToOrderItems < ActiveRecord::Migration
  class OnlineProduct < ActiveRecord::Base
    belongs_to :event
    belongs_to :purchasable, polymorphic: true, touch: true
    has_many :order_items
  end

  class Credit < ActiveRecord::Base
    has_one :online_product, as: :purchasable, dependent: :destroy
    has_one :preevent_item, as: :purchasable, dependent: :destroy
  end

  class OrderItem < ActiveRecord::Base
    belongs_to :order
    belongs_to :online_product
    belongs_to :preevent_item
  end

  class Entitlement < ActiveRecord::Base
  end

  def change
    add_column :order_items, :preevent_item_id, :integer

    add_preevent_items_to_credits
    migrate_entitlements_to_preevent_items
  end

  def add_preevent_items_to_credits
    OnlineProduct.all.each do |online_product|
      next unless online_product.purchasable_type == 'Credit'
      credit = online_product.purchasable
      preevent_item = PreeventItem.new(
        name: online_product.name,
        description: online_product.description,
        initial_amount: online_product.initial_amount,
        price: online_product.price,
        step: online_product.step,
        max_purchasable: online_product.max_purchasable,
        min_purchasable: online_product.min_purchasable,
        event_id: online_product.event_id
      )
      credit.update(preevent_item: preevent_item)
    end
    puts 'Credits Migrated √'
  end

  def migrate_entitlements_to_preevent_items
    Entitlement.all.map do |entitlement|
      preevent_item = PreeventItem.new(
        name: entitlement.name,
        description: 'Entitlement description',
        initial_amount: 0,
        price: 1,
        step: 1,
        max_purchasable: 50,
        min_purchasable: 1,
        event_id: entitlement.event_id
      )
      CredentialType.create(preevent_item: preevent_item, position: 1)
    end
    puts 'Entitlements Migrated √'
  end
end
