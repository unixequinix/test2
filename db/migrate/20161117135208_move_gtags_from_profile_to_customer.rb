class MoveGtagsFromProfileToCustomer < ActiveRecord::Migration
  def change
    add_reference :gtags, :customer, foreign_key: true, index: true

    sql = "UPDATE gtags GT
           SET customer_id = PR.customer_id
           FROM profiles PR
           WHERE PR.id = GT.profile_id"

    ActiveRecord::Base.connection.execute(sql)

    add_reference :transactions, :gtag


    # Link transactions to gtags
    puts "-- adding gtag_id to transactions (1 - link via profile if known)"

    sql = "UPDATE transactions TR
           SET gtag_id = GT.id
           FROM gtags GT
           WHERE GT.profile_id = TR.profile_id AND
                 GT.event_id = TR.event_id AND
                 TR.profile_id is not NULL"
    ActiveRecord::Base.connection.execute(sql)

    puts "-- adding gtag_id to transactions (1 - link via tag uid if profile null)"
    sql = "UPDATE transactions TR
           SET gtag_id = GT.id
           FROM gtags GT
           WHERE GT.tag_uid = TR.customer_tag_uid AND
                 GT.event_id = TR.event_id AND
                 TR.profile_id is NULL AND
                 TR.customer_tag_uid is not NULL"
    ActiveRecord::Base.connection.execute(sql)

    remove_reference :gtags, :profile
  end
end
