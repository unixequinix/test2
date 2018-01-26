module Transactions
  class Credential::TicketChecker < Transactions::Base
    TRIGGERS = %w[ticket_checkin ticket_validation].freeze

    queue_as :medium_low

    def perform(transaction, _atts = {})
      ticket = transaction.ticket
      # Remove integration absolut-manifesto when event finish
      transaction.customer.update(gtmid: ticket.gtmid) if transaction.event.id.eql?(266) && ticket.gtmid.present?
      ticket.redeemed? ? Alert.propagate(transaction.event, ticket, "has been redeemed twice") : ticket.update!(redeemed: true)

      if transaction.event.id.eql?(266) && transaction.type.eql?("CredentialTransaction") && transaction.action.eql?('ticket_checkin')

        params = {
          document_hostname: (Rails.env.production? ? 'absolutmanifesto.com' : 'testmanifest.com'),
          category: 'Event',
          action: 'Checked in',
          label: 'Absolut Manifesto',
          value: 1,
          document_title: transaction.device_created_at,
          user_id: transaction.customer.gtmid
        }

        tracker = Staccato.tracker(Rails.application.secrets.gtm_tracker, Rails.application.secrets.gtm_client, ssl: true)
        hit = tracker.build_event(params)
        hit.add_custom_dimension(1, transaction.customer.gtmid)
        hit.add_custom_dimension(2, 'Glownet')
        Rails.logger.info("GAGTM: #{Staccato.as_url(hit)}") if hit.track!
      end
    end
  end
end
