class Stats::Replacement < Stats::Base
  include StatsHelper

  TRIGGERS = %w[gtag_replacement].freeze

  def perform(transaction_id)
    t = CredentialTransaction.find(transaction_id)
    credential = t.event.gtags.find_by(tag_uid: t.ticket_code)

    atts = extract_credential_atts(credential, action: "replacement", name: "gtag")

    create_stat(extract_atts(t, atts))
  end
end
