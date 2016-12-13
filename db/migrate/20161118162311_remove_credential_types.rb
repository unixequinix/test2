class RemoveCredentialTypes < ActiveRecord::Migration
  def change
    add_reference :company_ticket_types, :catalog_item, index: true, foreign_key: true

    sql = "UPDATE company_ticket_types CTT
           SET catalog_item_id = CT.catalog_item_id
           FROM credential_types CT
           WHERE CT.id = CTT.credential_type_id"

    ActiveRecord::Base.connection.execute(sql)

    remove_reference :company_ticket_types, :credential_type
  end
end
