class ReaddColumnsToStats < ActiveRecord::Migration[5.1]
  def change
    add_column :stats, :final_balance, :decimal, precision: 8, scale: 2
    add_column :stats, :sale_item_total_price, :decimal, precision: 8, scale: 2
  end
end
