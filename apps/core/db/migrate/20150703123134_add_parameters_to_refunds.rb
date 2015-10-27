class AddParametersToRefunds < ActiveRecord::Migration
  def change
    add_reference :refunds, :claim, index: true, foreign_key: true
    add_column :refunds, :amount, :decimal, precision: 8, scale: 2, null: false
    add_column :refunds, :currency, :string
    add_column :refunds, :message, :string
    add_column :refunds, :operation_type, :string
    add_column :refunds, :gateway_transaction_number, :string
    add_column :refunds, :payment_solution, :string
    add_column :refunds, :status, :string
  end
end