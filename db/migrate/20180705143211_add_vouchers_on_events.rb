class AddVouchersOnEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :voucher_id, :integer, null: true
    add_column :events, :voucher_product_ids, :string, array: true, default: []
  end
end



