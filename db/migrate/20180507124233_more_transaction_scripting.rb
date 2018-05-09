class MoreTransactionScripting < ActiveRecord::Migration[5.1]
  def change
    ActiveRecord::Base.connection.execute("UPDATE transactions SET device_created_at_fixed = device_created_at WHERE device_created_at_fixed ISNULL;")

    SaleItem.where(credit_transaction: Transaction.where(device_id: nil, device_uid: nil)).delete_all
    Transaction.where(device_id: nil, device_uid: nil).delete_all

    SaleItem.where(credit_transaction: Transaction.where(device_uid: ["SERVER", "admin_panel", "portal"])).delete_all
    Transaction.where(device_uid: ["SERVER", "admin_panel", "portal"]).delete_all

    ids = []
    Transaction.select(:event_id, :device_id, :device_db_index, :device_created_at_fixed, :gtag_counter).group(:event_id, :device_id, :device_db_index, :device_created_at_fixed, :gtag_counter).having("count(*) > 1").size.each_pair do |arr, count|
      event_id, device_id, device_db_index, device_created_at_fixed, gtag_counter = arr
      all = Transaction.where(event_id: event_id, device_id: device_id, device_db_index: device_db_index, device_created_at_fixed: device_created_at_fixed, gtag_counter: gtag_counter).to_a
      all.pop
      ids << all.map(&:id)
    end

    SaleItem.where(credit_transaction: Transaction.where(id: ids.flatten)).delete_all
    Transaction.where(id: ids.flatten).delete_all
  end
end
