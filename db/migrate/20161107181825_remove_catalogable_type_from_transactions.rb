class RemoveCatalogableTypeFromTransactions < ActiveRecord::Migration
  def change
    remove_column :transactions, :catalogable_type, :string
  end
end
