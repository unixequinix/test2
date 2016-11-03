class RemoveColumnFromSaleItems < ActiveRecord::Migration
  def change
    remove_column :sale_items, :transaction_id, :integer
  end
end
