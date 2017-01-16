class AddDefaultToMemoeryLengthInAccesses < ActiveRecord::Migration[5.0]
  def change
    change_column_default :catalog_items, :memory_length, 1
  end
end
