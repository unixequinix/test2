class CreatePaymentGateways < ActiveRecord::Migration
  def change
    drop_table :payment_gateways if table_exists?(:payment_gateways)

    create_table :payment_gateways do |t|
      t.references :event, index: true, foreign_key: true
      t.string :gateway
      t.json :data

      t.timestamps null: false
    end
  end
end
