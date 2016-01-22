class AddTicketAssignationToEvents < ActiveRecord::Migration
  def change
    add_column :events, :ticket_assignation, :boolean, null: false, default: true
    rename_column :events, :gtag_registration, :gtag_assignation
  end
end
