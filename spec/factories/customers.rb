# == Schema Information
#
# Table name: customers
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  name                   :string           default(""), not null
#  surname                :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  confirmation_token     :string
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string
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
#

FactoryGirl.define do
  factory :customer do

    name { Faker::Name.name }
    surname { Faker::Name.last_name }
    email { Faker::Internet.email }
    agreed_on_registration true
    password 'password'
    phone { Faker::PhoneNumber.phone_number }
    country { Faker::Address.country_code }
    gender { ["male", "female"].sample }
    birthdate { Faker::Date.between(70.years.ago, 13.years.ago) }
    postcode { Faker::Address.postcode }
    event
  end
end
