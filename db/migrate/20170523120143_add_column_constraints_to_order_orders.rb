class AddColumnConstraintsToOrderOrders < ActiveRecord::Migration[5.1]
  def change
    change_column_default :orders, :payment_data, {}.to_json
    change_column_default :orders, :refund_data, {}.to_json
  end
end
