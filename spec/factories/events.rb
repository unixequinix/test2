# == Schema Information
#
# Table name: events
#
#  aasm_state                   :string
#  background_content_type      :string
#  background_file_name         :string
#  background_file_size         :integer
#  background_type              :string           default("fixed")
#  background_updated_at        :datetime
#  company_name                 :string
#  created_at                   :datetime         not null
#  currency                     :string           default("USD"), not null
#  device_basic_db_content_type :string
#  device_basic_db_file_name    :string
#  device_basic_db_file_size    :integer
#  device_basic_db_updated_at   :datetime
#  device_full_db_content_type  :string
#  device_full_db_file_name     :string
#  device_full_db_file_size     :integer
#  device_full_db_updated_at    :datetime
#  device_settings              :json
#  end_date                     :datetime
#  eventbrite_client_key        :string
#  eventbrite_client_secret     :string
#  eventbrite_event             :string
#  eventbrite_token             :string
#  gtag_assignation             :boolean          default(FALSE)
#  gtag_settings                :json
#  host_country                 :string           default("US"), not null
#  location                     :string
#  logo_content_type            :string
#  logo_file_name               :string
#  logo_file_size               :integer
#  logo_updated_at              :datetime
#  name                         :string           not null
#  official_address             :string
#  official_name                :string
#  registration_num             :string
#  registration_settings        :json
#  slug                         :string           not null
#  start_date                   :datetime
#  style                        :text
#  support_email                :string           default("support@glownet.com"), not null
#  ticket_assignation           :boolean          default(FALSE)
#  token                        :string
#  token_symbol                 :string           default("t")
#  updated_at                   :datetime         not null
#  url                          :string
#
# Indexes
#
#  index_events_on_slug  (slug) UNIQUE
#

FactoryGirl.define do
  factory :event do
    name { "Event #{SecureRandom.hex(16)}" }
    aasm_state "started"
    location "Glownet"
    start_date { Time.zone.now }
    end_date { Time.zone.now + 2.days }
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
    refund_success_message "Your refund has been successfull"
    gtag_settings { { gtag_type: "ultralight_c", maximum_gtag_balance: 300 }.as_json }

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
      ticket_assignation true
    end

    trait :gtag_assignation do
      gtag_assignation true
    end

    after :create do |event|
      event.create_credit(value: 1, step: 5, min_purchasable: 0, max_purchasable: 300, initial_amount: 0, name: "CR")
    end
  end
end
