class CreateCustomerCredits < ActiveRecord::Migration
  def change
    create_table :customer_credits do |t|
      t.references :customer_event_profile, null: false
      t.string :transaction_source, null: false
      t.string :payment_method, null: false
      t.decimal :amount, null: false
      t.decimal :refundable_amount, null: false
      t.decimal :final_balance, null: false
      t.decimal :final_refundable_balance, null: false
      t.decimal :credit_value, null: false

      t.datetime :deleted_at, index: true
      t.timestamps null: false
    end
  end
end
