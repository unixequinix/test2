class AddVirtualCreditsToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :standard_unit_price, :decimal, precision: 10, scale: 2
    add_column :stats, :standard_total_price, :decimal, precision: 10, scale: 2

    remove_column :stats, :final_balance, :decimal, precision: 8, scale: 2
    remove_column :stats, :sale_item_total_price, :decimal, precision: 8, scale: 2
  end
end
