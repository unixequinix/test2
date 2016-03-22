# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  first_name              :string           default(""), not null
#  last_name              :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#  agreed_on_registration :boolean          default(FALSE)
#  phone                  :string
#  postcode               :string
#  address                :string
#  city                   :string
#  country                :string
#  gender                 :string
#  birthdate              :datetime
#  event_id               :integer          not null
#  agreed_event_condition :boolean          default(FALSE)
#  remember_token         :string
#

FactoryGirl.define do
  factory :customer do
    first_name { "Some name #{rand(100)}" }
    last_name { "Some name #{rand(100)}" }
    email { "seth#{rand(10_000)}-#{rand(10_000)}@swift.name" }
    agreed_on_registration true
    encrypted_password Authentication::Encryptor.digest("password")
    phone { "1-800-#{rand(100)}" }
    country { %w( EN ES TH IT ).sample }
    gender { %w(male female).sample }
    birthdate { (13..70).to_a.sample.years.ago }
    postcode { "12345" }
    agreed_event_condition { [true, false].sample }
    event
    after(:build) do |customer|
      customer.customer_event_profile ||= build(:customer_event_profile, customer: customer)
    end
  end
end
