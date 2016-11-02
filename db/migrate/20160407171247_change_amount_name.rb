class ChangeAmountName < ActiveRecord::Migration
  def change
    rename_column :sale_items, :amount, :unit_price
  end
end
