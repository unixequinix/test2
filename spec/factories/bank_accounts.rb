# == Schema Information
#
# Table name: bank_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer          not null
#  iban        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  swift       :string
#

FactoryGirl.define do
  factory :bank_account do
    customer
    iban { Faker::Number.number(4) }
    swift { Faker::Number.number(8) }
  end
end
