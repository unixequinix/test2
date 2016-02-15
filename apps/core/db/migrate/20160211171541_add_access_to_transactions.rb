class AddAccessToTransactions < ActiveRecord::Migration
  def change
    create_table :access_entitlements do |t|
      t.timestamps
    end

    add_reference :transactions, :access_entitlement, index: true, foreign_key: true
    add_column :transactions, :direction, :integer
    add_column :transactions, :access_entitlement_value, :integer
  end
end
