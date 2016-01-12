class CreatePreeventProductUnits < ActiveRecord::Migration
  class Credit < ActiveRecord::Base
    has_one :online_product, as: :purchasable, dependent: :destroy
    has_one :preevent_product_unit, as: :purchasable, dependent: :destroy
    accepts_nested_attributes_for :preevent_product_unit, allow_destroy: true
  end

  def change
    create_table :preevent_product_units do |t|
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
    add_preevent_product_units_to_credits
  end

  def add_preevent_product_units_to_credits
    Credit.all.each do |credit|
      ppu = PreeventProductUnit.new(
        name: credit.online_product.name,
        description: credit.online_product.description,
        initial_amount: credit.online_product.initial_amount,
        price: credit.online_product.price,
        step: credit.online_product.step,
        max_purchasable: credit.online_product.max_purchasable
        min_purchasable: credit.online_product.min_purchasable
      )
      credit.update(preevent_product_unit: ppu)
    end
    puts "Credits Migrated √"
  end
end