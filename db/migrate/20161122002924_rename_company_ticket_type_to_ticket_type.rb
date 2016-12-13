class RenameCompanyTicketTypeToTicketType < ActiveRecord::Migration
  def change
    rename_table :company_ticket_types, :ticket_types

    rename_column :tickets, :company_ticket_type_id, :ticket_type_id
  end
end
