# == Schema Information
#
# Table name: events
#
#  id                      :integer          not null, primary key
#  name                    :string           not null
#  aasm_state              :string
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  slug                    :string           not null
#  location                :string
#  start_date              :datetime
#  end_date                :datetime
#  description             :text
#  support_email           :string           default("support@glownet.com"), not null
#  style                   :text
#  logo_file_name          :string
#  logo_content_type       :string
#  logo_file_size          :integer
#  logo_updated_at         :datetime
#  background_file_name    :string
#  background_content_type :string
#  background_file_size    :integer
#  background_updated_at   :datetime
#  url                     :string
#  background_type         :string           default("fixed")
#  features                :integer          default(0), not null
#  gtag_assignation        :boolean          default(TRUE), not null
#  payment_service         :string           default("redsys")
#  registration_parameters :integer          default(0), not null
#  currency                :string           default("USD"), not null
#  host_country            :string           default("US"), not null
#  locales                 :integer          default(1), not null
#  refund_services         :integer          default(0), not null
#  ticket_assignation      :boolean          default(TRUE), not null
#  token                   :string           not null
#

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

    # Payment services

    trait :payment_services do
      payment_services 3
    end

    trait :with_standard_credit do |_event|
    end

    after :create do |event|
      gtag_type = Parameter.find_by(category: "gtag", group: "form", name: "gtag_type")
      EventParameter.find_or_create_by(event: event, value: "ultralight_c", parameter: gtag_type)

      max_balance = Parameter.find_by(category: "gtag", group: "form", name: "maximum_gtag_balance")
      EventParameter.find_or_create_by(event: event, value: "300", parameter: max_balance)
    end

    factory :event_with_refund_services, traits: [:refund_services]
    factory :event_with_payment_services, traits: [:payment_services]
    factory :event_with_standard_credit, traits: [:with_standard_credit]
  end
end
