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
    name { "Festival #{SecureRandom.urlsafe_base64}" }
    location { "#{rand(100)} some street" }
    start_date { Time.now }
    end_date { Time.now + 2.days }
    description { "This paragraph is something special" }
    support_email "valid@email.com"
    style "html{color:white;}"
    url { "http://somedomain#{rand(100)}.example.com" }
    currency { "GBP" }
    host_country { "GB" }
    background_type { EventDecorator::BACKGROUND_TYPES.sample }
    disclaimer { ["word #{rand(10)}", "word #{rand(10)}"].join }
    gtag_assignation_notification { ["word #{rand(10)}", "word #{rand(10)}"].join }
    gtag_form_disclaimer { ["word #{rand(10)}", "word #{rand(10)}"].join }
    gtag_name { ["word #{rand(10)}", "word #{rand(10)}"].join }
    info { ["word #{rand(10)}", "word #{rand(10)}"].join }
    mass_email_claim_notification { ["word #{rand(10)}", "word #{rand(10)}"].join }
    refund_success_message { ["word #{rand(10)}", "word #{rand(10)}"].join }
    refund_services 0

    trait :refund_services do
      refund_services 2
    end

    factory :event_with_refund_services, traits: [:refund_services]
  end
end
