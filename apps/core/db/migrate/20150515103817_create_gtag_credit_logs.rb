class CreateGtagCreditLogs < ActiveRecord::Migration
  def change
    create_table :gtag_credit_logs do |t|
      t.belongs_to :gtag, null: false
      t.decimal :amount, precision: 8, scale: 2, null: false

      t.timestamps null: false
    end
  end
end
