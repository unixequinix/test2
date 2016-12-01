class AddIndexOnSaleItems < ActiveRecord::Migration
  def change
    all_item_transactions = ActiveRecord::Base.connection.execute("SELECT credit_transaction_id FROM sale_items;").column_values(0).uniq.map(&:to_i)
    all_transactions = Transaction.pluck(:id)
    SaleItem.where(credit_transaction_id: all_item_transactions - all_transactions).destroy_all
    add_foreign_key :sale_items, :transactions, column: :credit_transaction_id
  end
end
