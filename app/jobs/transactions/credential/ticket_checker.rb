module Transactions
  class Credential::TicketChecker < Transactions::Base
    TRIGGERS = %w[ticket_checkin ticket_validation].freeze

    queue_as :medium_low

    def perform(transaction, _atts = {})
      ticket = transaction.ticket
      ticket.redeemed? ? Alert.propagate(transaction.event, ticket, "has been redeemed twice") : ticket.update!(redeemed: true)
    end
  end
end
