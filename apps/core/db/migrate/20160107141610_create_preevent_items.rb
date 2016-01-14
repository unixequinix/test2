class CreatePreeventItems < ActiveRecord::Migration
  class OnlineProduct < ActiveRecord::Base
    belongs_to :event
    belongs_to :purchasable, polymorphic: true, touch: true
    has_many :order_items
  end

  class Credit < ActiveRecord::Base
    has_one :online_product, as: :purchasable, dependent: :destroy
    has_one :preevent_item, as: :purchasable, dependent: :destroy
  end

  def change
    create_table :preevent_items do |t|
      t.references :purchasable, polymorphic: true, null: false
      t.integer :event_id
      t.string :name
      t.text :description
      t.integer :initial_amount
      t.decimal :price
      t.integer :step
      t.integer :max_purchasable
      t.integer :min_purchasable

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    add_preevent_items_to_credits
    migrate_entitlements_to_preevent_items
  end

  def add_preevent_items_to_credits
    OnlineProduct.all.each do |online_product|
      if online_product.purchasable_type == "Credit"
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
    end
    puts "Credits Migrated √"
  end

  def migrate_entitlements_to_preevent_items
    Entitlement.all.each do |entitlement|
      preevent_item = PreeventItem.new(
        name: entitlement.name,
        description: "Entitlement description",
        initial_amount: 0,
        price: 1,
        step: 1,
        max_purchasable: 50,
        min_purchasable: 1,
        event_id: entitlement.event_id
      )
      credential_type = CredentialType.create(preevent_item: preevent_item, position: 1)
    end
    puts "Entitlements Migrated √"
  end
end
