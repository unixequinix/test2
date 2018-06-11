class RemovePriceFromTicketTypes < ActiveRecord::Migration[5.1]
  def change
    remove_column :ticket_types, :money_base, :decimal, precision: 8, scale: 2, default: "0.0", null: false
    remove_column :ticket_types, :money_fee, :decimal, precision: 8, scale: 2, default: "0.0", null: false
  end
end
