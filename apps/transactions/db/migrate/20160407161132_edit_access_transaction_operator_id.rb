class EditAccessTransactionOperatorId < ActiveRecord::Migration
  def change
    remove_index :access_transactions, name: "index_access_transactions_on_operator_id"
    remove_column :access_transactions, :operator_id
    add_column :access_transactions, :operator_tag_uid, :string
  end
end
