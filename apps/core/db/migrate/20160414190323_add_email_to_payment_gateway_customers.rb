class AddEmailToPaymentGatewayCustomers < ActiveRecord::Migration
  def change
    add_column :payment_gateway_customers, :email, :string
  end
end
