class AddColumnConstraintsToTicketTypes < ActiveRecord::Migration[5.1]
  def change
    change_column_null :ticket_types, :name, false
    change_column_null :ticket_types, :company_id, false
  end
end
