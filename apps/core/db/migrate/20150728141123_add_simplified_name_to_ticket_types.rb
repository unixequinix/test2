class AddSimplifiedNameToTicketTypes < ActiveRecord::Migration
  def change
    add_column :ticket_types, :simplified_name, :string
  end
end