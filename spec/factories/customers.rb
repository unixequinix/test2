# == Schema Information
#
# Table name: customers
#
#  address                    :string
#  agreed_event_condition     :boolean          default(FALSE)
#  agreed_on_registration     :boolean          default(FALSE)
#  banned                     :boolean
#  birthdate                  :datetime
#  city                       :string
#  country                    :string
#  created_at                 :datetime         not null
#  current_sign_in_at         :datetime
#  current_sign_in_ip         :inet
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string           default(""), not null
#  gender                     :string
#  last_name                  :string           default(""), not null
#  last_sign_in_at            :datetime
#  last_sign_in_ip            :inet
#  locale                     :string           default("en")
#  phone                      :string
#  postcode                   :string
#  receive_communications     :boolean          default(FALSE)
#  receive_communications_two :boolean          default(FALSE)
#  remember_created_at        :datetime
#  remember_token             :string
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  sign_in_count              :integer          default(0), not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_customers_on_event_id              (event_id)
#  index_customers_on_remember_token        (remember_token) UNIQUE
#  index_customers_on_reset_password_token  (reset_password_token) UNIQUE
#
# Foreign Keys
#
#  fk_rails_0b9257e0c6  (event_id => events.id)
#

FactoryGirl.define do
  factory :customer do
    first_name { "FirstName #{rand(100)}" }
    last_name { "LastName #{rand(100)}" }
    email { "email_#{rand(10_000)}@glownet.com" }
    agreed_on_registration true
    password "password"
    password_confirmation "password"
    phone { "1-800-#{rand(100)}" }
    country { %w( EN ES TH IT ).sample }
    gender { %w(male female).sample }
    birthdate { (13..70).to_a.sample.years.ago }
    postcode { "12345" }
    agreed_event_condition true
    event
  end
end
