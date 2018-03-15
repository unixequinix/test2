class AddCompanyToTicketTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :ticket_types, :company, :string, default: "Glownet"
  end
end
