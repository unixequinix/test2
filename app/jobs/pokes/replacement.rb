class Pokes::Replacement < Pokes::Base
  include PokesHelper

  TRIGGERS = %w[gtag_replacement].freeze

  def perform(t)
    credential = t.event.gtags.find_by(tag_uid: t.ticket_code)
    create_poke(extract_atts(t, extract_credential_info(credential, action: "replacement", description: "gtag")))
  end
end
