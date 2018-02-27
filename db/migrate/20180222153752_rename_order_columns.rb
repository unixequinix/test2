class RenameOrderColumns < ActiveRecord::Migration[5.1]
  def change
    remove_column :orders, :refund_data
    remove_column :orders, :previous_balance

    rename_column :orders, :fee, :money_fee
    rename_column :orders, :price_money, :money_base
    remove_column :orders, :amount
  end
end
