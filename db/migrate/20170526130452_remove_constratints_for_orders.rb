class RemoveConstratintsForOrders < ActiveRecord::Migration[5.1]
  def change
    change_column_null :orders, :payment_data, true
    change_column_null :orders, :refund_data, true
  end
end
