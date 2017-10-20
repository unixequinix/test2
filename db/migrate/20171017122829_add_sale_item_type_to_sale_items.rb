class AddSaleItemTypeToSaleItems < ActiveRecord::Migration[5.1]
  def change
    add_column :sale_items, :sale_item_type, :string
  end
end
