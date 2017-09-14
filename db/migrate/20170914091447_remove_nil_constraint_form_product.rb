class RemoveNilConstraintFormProduct < ActiveRecord::Migration[5.1]
  def change
    change_column_null :sale_items, :product_id, true
  end
end
