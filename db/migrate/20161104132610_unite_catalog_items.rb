class UniteCatalogItems < ActiveRecord::Migration
  def change
    add_column :catalog_items, :standard, :boolean, default: false, null: false
    add_column :catalog_items, :value, :decimal, precision: 8, scale: 2, default: 1.0, null: false
    add_column :catalog_items, :currency, :string
    rename_column :catalog_items, :catalogable_type, :type

    remove_index :topup_credits, :credit_id
    remove_index :transactions, :access_id
    remove_index :pack_catalog_items, :pack_id
    remove_foreign_key :topup_credits, :credits

    sql = "UPDATE catalog_items CI
           SET standard = CR.standard, value = CR.value, currency = CR.currency
           FROM credits CR
           WHERE CI.catalogable_id = CR.id and CI.type = 'Credit';

           UPDATE access_control_gates ACG
           SET access_id = CI.id
           FROM catalog_items CI
           WHERE ACG.access_id = CI.catalogable_id AND CI.type = 'Access';

           UPDATE pack_catalog_items PCI
           SET pack_id = CI.id
           FROM catalog_items CI
           WHERE PCI.pack_id = CI.catalogable_id AND CI.type = 'Pack';

           UPDATE entitlements ENT
           SET entitlementable_id = CI.id
           FROM catalog_items CI
           WHERE ENT.entitlementable_id = CI.catalogable_id AND CI.type = 'Access';

           UPDATE topup_credits TUC
           SET credit_id = CI.id
           FROM catalog_items CI
           WHERE TUC.credit_id = CI.catalogable_id AND CI.type = 'Credit';

           UPDATE transactions TS
           SET access_id = CI.id
           FROM catalog_items CI
           WHERE TS.access_id = CI.catalogable_id AND CI.type = 'Access';

           UPDATE transactions TS
           SET catalogable_id = CI.id
           FROM catalog_items CI
           WHERE TS.catalogable_id = CI.catalogable_id AND TS.type = CI.type"

    ActiveRecord::Base.connection.execute(sql)
    remove_column :catalog_items, :catalogable_id
    drop_table :accesses
    drop_table :credits
    drop_table :packs
  end
end
