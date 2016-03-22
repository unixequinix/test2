class AddAggrementToPaymentGatewayCustomers < ActiveRecord::Migration
  def change
    add_column :payment_gateway_customers, :agreement_accepted, :boolean, null: false,
               default: false
    add_column :payment_gateway_customers, :autotopup_amount, :integer, precision: 8, scale: 2
  end
end
