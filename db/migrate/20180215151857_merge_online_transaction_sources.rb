class MergeOnlineTransactionSources < ActiveRecord::Migration[5.1]
  def change
    Transaction.where(transaction_origin: %w[admin_panel customer_portal api]).update_all(transaction_origin: "online")
  end
end
