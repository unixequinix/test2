class RefactorCompanyTicketTypes < ActiveRecord::Migration
  def change
    remove_reference :company_ticket_types, :company
    add_reference :company_ticket_types, :company_event_agreement
  end
end
