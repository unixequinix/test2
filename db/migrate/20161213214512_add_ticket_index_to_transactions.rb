class AddTicketIndexToTransactions < ActiveRecord::Migration
  def change
    add_index :transactions, :ticket_id
    add_foreign_key :transactions, :tickets
  end
end
