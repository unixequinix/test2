class DropVouchers < ActiveRecord::Migration
  def change
    drop_table :vouchers
    drop_table :products_vouchers
  end
end
