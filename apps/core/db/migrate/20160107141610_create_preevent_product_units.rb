class CreatePreeventProductUnits < ActiveRecord::Migration
  class Credit < ActiveRecord::Base
    has_one :online_product, as: :purchasable, dependent: :destroy
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

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    move_credits_to_preevent_product_units
  end

  def move_credits_to_preevent_product_units
    list_preevent_product_unit = Credit.all.map do |credit|
      ppu = PreeventProductUnit.new(
        name: credit.online_product.name,
        description: credit.online_product.description,
        initial_amount: credit.online_product.initial_amount,
        price: credit.online_product.price,
        step: credit.online_product.step,
        max_purchasable: credit.online_product.max_purchasable
      )
      Credit.new(standard: credit.standard, preevent_product_unit: ppu)
    end
    CredentialAssignment.import(list_preevent_product_unit)
    puts "Credits Imported √"
  end
end