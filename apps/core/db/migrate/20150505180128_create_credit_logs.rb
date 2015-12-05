class CreateCreditLogs < ActiveRecord::Migration
  def change
    create_table :credit_logs do |t|
      t.belongs_to :customer, null: false
      t.string :transaction_type
      t.decimal :amount, precision: 8, scale: 2, null: false

      t.timestamps null: false
    end
  end
end
