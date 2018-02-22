class Pokes::Checkin < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[ticket_checkin gtag_checkin ticket_validation].freeze

  def perform(t)
    credential = t.ticket
    credential = t.gtag if t.action.eql?("gtag_checkin")
    return unless credential

    credential.redeemed? ? Alert.propagate(t.event, credential, "has been redeemed twice") : credential.update!(redeemed: true)

    atts = t.action.include?("checkin") ? { action: "checkin", description: t.action.gsub("_checkin", "") } : { action: "ticket_validation" }
    atts.merge!(extract_catalog_item_info(credential.ticket_type&.catalog_item, extract_credential_info(credential)))

    create_poke(extract_atts(t, atts))
  end
end
