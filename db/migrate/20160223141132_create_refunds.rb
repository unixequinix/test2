class CreateRefunds < ActiveRecord::Migration
  def change
    create_table :refunds do |t|
      t.references :claim, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false
      t.string :currency
      t.string :message
      t.string :operation_type
      t.string :gateway_transaction_number
      t.string :payment_solution
      t.string :status
      t.timestamps null: false
    end
  end
end
