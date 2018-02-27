class RemoveNullConstraintFromSaleItemsUnitPrice < ActiveRecord::Migration[5.1]
  def change
    change_column_null :sale_items, :unit_price, true
  end
end
