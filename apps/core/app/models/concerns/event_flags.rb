module EventFlags
  extend ActiveSupport::Concern

  included do
    include FlagShihTzu

    has_flags(
      1 => :top_ups,
      2 => :refunds,
      3 => :ticket_assignation,
      4 => :gtag_assignation,
      5 => :agreement_acceptance,
      6 => :authorization,
      column: "features"
    )
    has_flags(
      1 => :paypal,
      2 => :redsys,
      3 => :braintree,
      4 => :stripe,
      5 => :paypal_nvp,
      6 => :ideal,
      7 => :sofort,
      8 => :wirecard,
      column: "payment_services"
    )
    has_flags(
      1 => :bank_account,
      2 => :epg,
      3 => :tipalti,
      4 => :direct,
      column: "refund_services"
    )
    has_flags(
      1 => :phone,
      2 => :address,
      3 => :city,
      4 => :country,
      5 => :postcode,
      6 => :gender,
      7 => :birthdate,
      8 => :agreed_event_condition,
      column: "registration_parameters"
    )
    has_flags(
      1 => :en_lang,
      2 => :es_lang,
      3 => :it_lang,
      4 => :th_lang,
      5 => :de_lang,
      column: "locales"
    )
  end
end
