class RenameRefundColumns < ActiveRecord::Migration[5.1]
  def change
    rename_column :refunds, :fee, :credit_fee
    rename_column :refunds, :amount, :credit_base
  end
end
