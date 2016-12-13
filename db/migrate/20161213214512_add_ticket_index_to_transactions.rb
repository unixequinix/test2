class AddTicketIndexToTransactions < ActiveRecord::Migration
  def change
    all_transaction_tickets = ActiveRecord::Base.connection.execute("SELECT ticket_id FROM transactions;").column_values(0).uniq.map(&:to_i)
    all_tickets = Ticket.pluck(:id)
    Transaction.where(ticket_id: all_transaction_tickets - all_tickets).update_all(ticket_id: nil)

    add_index :transactions, :ticket_id
    add_foreign_key :transactions, :tickets
  end
end
