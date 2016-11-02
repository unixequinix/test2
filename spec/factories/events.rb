FactoryGirl.define do
  factory :event do
    name { "Event #{SecureRandom.hex(16)}" }
    location "Glownet"
    start_date { Time.zone.now }
    end_date { Time.zone.now + 2.days }
    description "This paragraph is something special"
    support_email "support@glownet.com"
    style "html { font-family: Helvetica; }"
    url { "somedomain#{rand(100)}.example.com" }
    currency "EUR"
    host_country "ES"
    background_type "fixed"
    disclaimer "Some Disclaimer"
    gtag_assignation_notification "Some gtag assignation notification"
    gtag_form_disclaimer "Some gtag form notification"
    gtag_name "Wristband"
    info "Information about the festival"
    mass_email_claim_notification "We are sending you email"
    refund_success_message "Your refund has been successfull"
    refund_services 0
    payment_services 0

    # Event states

    trait :pre_event do
      aasm_state "launched"
    end

    trait :started do
      aasm_state "started"
    end

    trait :finished do
      aasm_state "finished"
    end

    trait :closed do
      aasm_state "closed"
    end

    # Event features

    trait :ticket_assignation do
      after(:build) do |event|
        event.ticket_assignation = true
      end
    end

    trait :gtag_assignation do
      after(:build) do |event|
        event.gtag_assignation = true
      end
    end

    # Payment services
    trait :payment_services do
      payment_services 3
    end

    # Refund services
    trait :refunds do
      after(:build) do |event|
        event.refunds = true
      end
    end

    trait :with_standard_credit do |_event|
    end

    after :create do |event|
      gtag_type = Parameter.find_by(category: "gtag", group: "form", name: "gtag_type")
      EventParameter.find_or_create_by(event: event, value: "ultralight_c", parameter: gtag_type)

      max_balance = Parameter.find_by(category: "gtag", group: "form", name: "maximum_gtag_balance")
      EventParameter.find_or_create_by(event: event, value: "300", parameter: max_balance)

      ci = { event_id: event.id, name: "Credit", step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0 }
      Credit.create(standard: true, currency: "EUR", value: 1, catalog_item_attributes: ci)
    end

    factory :event_with_refund_services, traits: [:refund_services]
    factory :event_with_payment_services, traits: [:payment_services]
    factory :event_with_standard_credit, traits: [:with_standard_credit]
  end
end
