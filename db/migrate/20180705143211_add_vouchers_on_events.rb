class AddVouchersOnEvents < ActiveRecord::Migration[5.1]
  def change
    add_column :events, :voucher_id, :integer, null: true
    add_column :events, :voucher_products, :string, array: true, default: []
  end
end



