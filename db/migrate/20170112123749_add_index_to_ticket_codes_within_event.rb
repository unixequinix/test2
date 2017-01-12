class AddIndexToTicketCodesWithinEvent < ActiveRecord::Migration[5.0]
  def change
    tickets = Ticket.select(:event_id, :code).group(:event_id, :code).having("count(*) > 1").map(&:code)
    Ticket.where(code: tickets).group_by(&:code).each do |_, tickets|
      next if tickets.size == 1
      first = tickets.first
      rest = tickets.drop(1)
      Transaction.where(ticket: rest).update_all(ticket: first, updated_at: Time.zone.now)
      rest.map(&:delete)
    end

    add_index :tickets, [:event_id, :code], unique: true
  end
end
