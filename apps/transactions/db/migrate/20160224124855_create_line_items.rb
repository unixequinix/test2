class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :onsite_products do
    end

    create_table :transaction_sale_items do |t|
      t.references :onsite_product
      t.integer :quantity
      t.float :total_price_paid
      t.references :monetary_transaction
    end
  end
end
