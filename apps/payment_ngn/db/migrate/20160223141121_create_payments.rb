class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :order, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.string :terminal
      t.string :transaction_type
      t.string :card_country
      t.string :response_code
      t.string :authorization_code
      t.string :currency
      t.string :merchant_code
      t.string :payment_type
      t.string :last4
      t.boolean :success

      t.datetime :paid_at
      t.timestamps null: false
    end
  end
end
