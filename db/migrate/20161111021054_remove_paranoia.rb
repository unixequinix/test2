class RemoveParanoia < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("UPDATE catalog_items SET deleted_at = NULL")

    clases = %w(catalog_items access_control_gates claims companies company_event_agreements company_ticket_types customers entitlements gtags order_items orders pack_catalog_items products station_catalog_items station_products stations tickets topup_credits)

    clases.each do |klass|
      puts "-- removing deleted_at from #{klass}"
      sql = "DELETE FROM #{klass} WHERE deleted_at IS NOT NULL;"
      ActiveRecord::Base.connection.execute(sql)
    end

    remove_column :access_control_gates, :deleted_at
    remove_column :catalog_items, :deleted_at
    remove_column :claims, :deleted_at
    remove_column :companies, :deleted_at
    remove_column :company_event_agreements, :deleted_at
    remove_column :company_ticket_types, :deleted_at
    remove_column :credential_types, :deleted_at
    remove_column :customer_credits, :deleted_at
    remove_column :customers, :deleted_at
    remove_column :entitlements, :deleted_at
    remove_column :gtags, :deleted_at
    remove_column :order_items, :deleted_at
    remove_column :orders, :deleted_at
    remove_column :pack_catalog_items, :deleted_at
    remove_column :products, :deleted_at
    remove_column :profiles, :deleted_at
    remove_column :station_catalog_items, :deleted_at
    remove_column :station_products, :deleted_at
    remove_column :stations, :deleted_at
    remove_column :tickets, :deleted_at
    remove_column :topup_credits, :deleted_at
  end
end
