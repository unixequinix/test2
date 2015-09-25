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
#  refund_service          :string           default("bank_account")
#  gtag_registration       :boolean          default(TRUE), not null
#  payment_service         :string           default("redsys")
#  registration_parameters :integer          default(0), not null
#

FactoryGirl.define do
  factory :event do
    name { Faker::Lorem.words(2).join + Faker::Code.ean }
    location { Faker::Address.street_address }
    start_date { Time.now }
    end_date { Time.now + 2.days }
    description { Faker::Lorem.paragraph }
    support_email 'valid@email.com'
    style 'html{color:white;}'
    url { Faker::Internet.url }
    background_type { Event::BACKGROUND_TYPES.sample }
    disclaimer { Faker::Lorem.words(2).join }
    gtag_assignation_notification { Faker::Lorem.words(2).join }
    gtag_form_disclaimer { Faker::Lorem.words(2).join }
    gtag_name { Faker::Lorem.words(2).join }
    info { Faker::Lorem.words(2).join }
    mass_email_claim_notification { Faker::Lorem.words(2).join }
    refund_success_message { Faker::Lorem.words(2).join }
  end
end
