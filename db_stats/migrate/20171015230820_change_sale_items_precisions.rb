class ChangeSaleItemsPrecisions < ActiveRecord::Migration[5.1]
  def change
    change_column :stats, :sale_item_unit_price, :decimal, precision: 10, scale: 2
    change_column :stats, :sale_item_total_price, :decimal, precision: 10, scale: 2
  end
end
