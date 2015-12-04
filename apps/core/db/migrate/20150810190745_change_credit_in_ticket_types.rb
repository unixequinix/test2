class ChangeCreditInTicketTypes < ActiveRecord::Migration
  def change
    change_column :ticket_types, :credit, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end