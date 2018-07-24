class RemoveVouchersFromEvents < ActiveRecord::Migration[5.1]
  def change
    remove_column :events, :voucher_id, :integer, null: true
    remove_column :events, :voucher_products, :string, array: true
  end
end
