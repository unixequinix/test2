class RemoveAgainColumnsFromStats < ActiveRecord::Migration[5.1]
  def change
    remove_column(:stats, :final_balance, :decimal, precision: 8, scale: 2) if column_exists?(:stats, :final_balance)
    remove_column(:stats, :sale_item_total_price, :decimal, precision: 8, scale: 2) if column_exists?(:stats, :sale_item_total_price)
  end
end
