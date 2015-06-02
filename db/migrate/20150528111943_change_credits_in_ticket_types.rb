class ChangeCreditsInTicketTypes < ActiveRecord::Migration
  def change
    change_column :ticket_types, :credit, :decimal, precision: 8, scale: 2, null: true
  end
end
