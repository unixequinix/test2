class ChangeOrdersPaymentRefundDataDefault < ActiveRecord::Migration[5.1]
  def change
    change_column_default :orders, :payment_data, {}
    change_column_default :orders, :refund_data, {}
  end
end
