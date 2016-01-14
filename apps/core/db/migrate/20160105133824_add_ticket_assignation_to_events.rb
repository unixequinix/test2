class AddTicketAssignationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :ticket_assignation, :boolean, null: false, default: true
  end
end
