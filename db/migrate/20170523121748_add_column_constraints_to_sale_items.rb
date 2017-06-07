class AddColumnConstraintsToSaleItems < ActiveRecord::Migration[5.1]
  def change
    SaleItem.where(credit_transaction_id: nil).destroy_all

    change_column_null :sale_items, :product_id, false
    change_column_null :sale_items, :quantity, false
    change_column_null :sale_items, :unit_price, false
    change_column_null :sale_items, :credit_transaction_id, false
  end
end
