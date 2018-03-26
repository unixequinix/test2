class AddMoneyAttsToTicketTypes < ActiveRecord::Migration[5.1]
  def change
    add_column :ticket_types, :money_base, :decimal, precision: 8, scale: 2, default: "0.0", null: false
    add_column :ticket_types, :money_fee, :decimal, precision: 8, scale: 2, default: "0.0", null: false
  end
end
