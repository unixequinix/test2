class AddStandardUnitPriceToSaleItems < ActiveRecord::Migration[5.1]
  def change
    rename_column :sale_items, :unit_price, :standard_unit_price
  end
end
