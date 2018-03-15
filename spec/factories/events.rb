FactoryBot.define do
  factory :event do
    name { "Event #{SecureRandom.hex(4)}" }
    state "launched"
    start_date { Time.zone.now }
    end_date { Time.zone.now + 2.days }
    support_email "support@glownet.com"
    currency "EUR"
    gtag_type "ultralight_c"
    open_api true
    open_devices_api true
    open_portal true
    open_refunds true
    open_topups true
    open_tickets true
    open_gtags true
    event_serie_id nil

    # Event states

    trait :launched do
      state "launched"
    end

    trait :closed do
      state "closed"
    end

    after :create do |event|
      event.create_credit(value: 1, name: "CRD") if event.credit.blank?
      event.create_virtual_credit(value: 1, name: "Virtual") if event.virtual_credit.blank?
    end
  end
end
