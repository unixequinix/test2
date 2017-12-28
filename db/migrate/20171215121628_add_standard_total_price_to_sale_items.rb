class AddStandardTotalPriceToSaleItems < ActiveRecord::Migration[5.1]
  def change
    add_column :sale_items, :standard_total_price, :decimal, precision: 10, scale: 2
  end
end
