class DropTablePaymentGatewayCustomers < ActiveRecord::Migration
  def change
    drop_table :payment_gateway_customers if table_exists?(:payment_gateway_customers)
  end
end
