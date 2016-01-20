class RenameColumnCodeInCompanyTicketTypeToInternalTicketType < ActiveRecord::Migration
  def change
    rename_column :company_ticket_types, :code, :internal_ticket_type
  end
end
