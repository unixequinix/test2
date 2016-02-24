class AddAccessTransactions < ActiveRecord::Migration
  def change
    create_table :access_transactions do |t|
      t.references :transaction
      t.integer :direction
      t.references :access_entitlement
      t.integer :access_entitlement_value
    end

    remove_column :transactions, :direction
    remove_column :transactions, :access_entitlement_id
    remove_column :transactions, :access_entitlement_value
  end
end
