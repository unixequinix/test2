class RefactorOrders < ActiveRecord::Migration
  def change
    add_column :orders, :payment_data, :json
    add_column :transactions, :order_id, :integer
  end
end
