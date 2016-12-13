class RemoveProfileFromTransactions < ActiveRecord::Migration
  def change
    # Updating origins and transaction_types
    puts "-- removing origin 'device'"
    sql = "UPDATE transactions TR
           SET transaction_origin = 'onsite'
           WHERE TR.transaction_origin = 'device'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing origin 'refund'"
    sql = "UPDATE transactions TR
           SET transaction_origin = 'customer_portal'
           WHERE TR.transaction_origin = 'refund'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'online_topup'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'topup'
           WHERE TR.transaction_type = 'online_topup'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'online_refund'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'refund'
           WHERE TR.transaction_type = 'online_refund'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'portal_purchase'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'online_purchase'
           WHERE TR.transaction_type = 'portal_purchase'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'portal_refund'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'online_refund'
           WHERE TR.transaction_type = 'portal_refund'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'ticket_credit'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'topup'
           WHERE TR.transaction_type = 'ticket_credit'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'create_credit'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'topup'
           WHERE TR.transaction_type = 'create_credit'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- adding status_message 'FIX' to sale transactions created in the portal"
    sql = "UPDATE transactions TR
           SET status_message = 'FIX'
           WHERE TR.transaction_type = 'sale' AND TR.transaction_origin IN ('admin_panel', 'customer_portal')"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- adjusting origin for 'script' transactions"
    sql = "UPDATE transactions TR
           SET transaction_origin = 'admin_panel', status_message = 'FIX'
           WHERE TR.transaction_type = 'script' AND TR.transaction_origin IN ('admin_panel', 'customer_portal')"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- adding status_message 'FIX' to sale transactions created in the admin panel"
    sql = "UPDATE transactions TR
           SET status_message = 'FIX'
           WHERE TR.transaction_type IN ('topup', 'refund') AND TR.transaction_origin = 'admin_panel'"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- removing type 'script'"
    sql = "UPDATE transactions TR
           SET transaction_type = 'correction'
           WHERE TR.transaction_type = 'script'"
    ActiveRecord::Base.connection.execute(sql)

    add_reference :transactions, :customer

    sql = "UPDATE transactions TR
           SET customer_id = PR.customer_id
           FROM profiles PR
           WHERE PR.id = TR.profile_id
             AND transaction_origin IN ('customer_portal', 'admin_panel')"
    ActiveRecord::Base.connection.execute(sql)

    remove_reference :transactions, :profile
    remove_column :transactions, :owner_id
    remove_column :transactions, :owner_type
    remove_column :transactions, :credit_value
    rename_column :transactions, :transaction_type, :action
  end
end