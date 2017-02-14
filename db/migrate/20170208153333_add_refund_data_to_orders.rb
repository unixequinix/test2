class AddRefundDataToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :refund_data, :jsonb, default: {}, null: false
  end
end
