class CreatePaymentGatewayCustomers < ActiveRecord::Migration
  def change
    create_table :payment_gateway_customers do |t|
      t.references :customer_event_profile
      t.string :token
      t.string :gateway_type, index: true

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
    add_index :payment_gateway_customers, [:token, :gateway_type], unique: true
  end
end
