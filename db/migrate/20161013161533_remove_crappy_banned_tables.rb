class RemoveCrappyBannedTables < ActiveRecord::Migration
  def change
    drop_table :banned_gtags if ActiveRecord::Base.connection.table_exists? :banned_gtags
    drop_table :alex_tags_complete if ActiveRecord::Base.connection.table_exists? :alex_tags_complete
    drop_table :banned_customer_event_profiles if ActiveRecord::Base.connection.table_exists? :banned_customer_event_profiles
    drop_table :banned_tickets if ActiveRecord::Base.connection.table_exists? :banned_tickets
    drop_table :customer_event_profiles if ActiveRecord::Base.connection.table_exists? :customer_event_profiles
  end
end
