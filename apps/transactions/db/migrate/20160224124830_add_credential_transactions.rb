class AddCredentialTransactions < ActiveRecord::Migration
  def change
    create_table :credential_transactions do |t|
      t.references :transaction
      t.references :ticket
      t.references :preevent_product
    end

    remove_column :transactions, :ticket_id
    remove_column :transactions, :preevent_product_id
  end
end
