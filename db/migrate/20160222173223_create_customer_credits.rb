class CreateCustomerCredits < ActiveRecord::Migration
  def change
    create_table :customer_credits do |t|
      t.references :customer_event_profile, null: false
      t.string :transaction_source, null: false
      t.string :payment_method, null: false
      t.decimal :amount, precision: 8, scale: 2, default: 1.0, null: false
      t.decimal :refundable_amount, precision: 8, scale: 2, default: 1.0, null: false
      t.decimal :final_balance, precision: 8, scale: 2, default: 1.0, null: false
      t.decimal :final_refundable_balance, precision: 8, scale: 2, default: 1.0, null: false
      t.decimal :credit_value, precision: 8, scale: 2, default: 1.0, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
