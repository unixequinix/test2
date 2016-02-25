# == Schema Information
#
# Table name: customer_credits
#
#  id                        :integer          not null, primary key
#  customer_event_profile_id :integer          not null
#  amount                    :decimal(, )      not null
#  refundable_amount         :decimal(, )      not null
#  final_balance             :decimal(, )      not null
#  final_refundable_balance  :decimal(, )      not null
#  value_credit              :decimal(, )      not null
#  payment_method            :string           not null
#  transaction_source         :string           not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :customer_credit do
    customer_event_profile

    trait :hospitality do
      amount 10
      refundable_amount 0
      value_credit 1
      payment_method "none"
      transaction_source "offline"
    end

    trait :online do
      amount 20
      refundable_amount 20
      value_credit 1
      payment_method { %w(cash card paypal).sample }
      transaction_source "online"
    end

    trait :onsite do
      amount 15
      refundable_amount 5
      value_credit 1
      payment_method { %w(cash card paypal).sample }
      transaction_source "offline"
    end

    after :build do |customer_credit|
      customer_credit.final_balance = CustomerCredit.select("sum(amount) as final_balance, sum(refundable_amount) as final_refundable_balance").where(customer_event_profile: customer_credit.customer_event_profile)[0].final_balance.to_i
      customer_credit.final_refundable_balance = CustomerCredit
        .select("sum(amount) as final_balance, sum(refundable_amount) as final_refundable_balance")
        .where(customer_event_profile: customer_credit.customer_event_profile)[0]
        .final_refundable_balance.to_i
    end

    factory :customer_credit_hospitality, traits: [:hospitality]
    factory :customer_credit_online, traits: [:online]
    factory :customer_credit_onsite, traits: [:onsite]
  end
end
