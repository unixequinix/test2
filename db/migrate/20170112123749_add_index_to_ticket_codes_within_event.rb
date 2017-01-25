class AddIndexToTicketCodesWithinEvent < ActiveRecord::Migration[5.0]
  def change
    tickets = Ticket.select(:event_id, :code).group(:event_id, :code).having("count(*) > 1").map(&:code)
    Ticket.where(code: tickets).group_by { |ticket| [ticket.code.upcase, ticket.event_id] }.each_pair do |_, tickets|
      first = tickets.first
      rest = tickets.drop(1)
      Transaction.where(ticket_id: rest.map(&:id)).update_all(ticket_id: first.id, updated_at: Time.zone.now)
      rest.map(&:delete)
    end

    add_index :tickets, [:code, :event_id], unique: true
    change_column :transactions, :ticket_code, :citext
  end
end
