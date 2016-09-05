class AddHiddenToCompanyTicketTypes < ActiveRecord::Migration
  def change
    add_column :company_ticket_types, :hidden, :boolean, default: false
  end
end
