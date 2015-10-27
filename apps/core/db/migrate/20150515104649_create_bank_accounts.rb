class CreateBankAccounts < ActiveRecord::Migration
  def change
    create_table :bank_accounts do |t|
      t.belongs_to :customer, null: false
      t.string :number, null: false

      t.timestamps null: false
    end
  end
end
