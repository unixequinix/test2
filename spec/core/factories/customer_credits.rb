# == Schema Information
#
# Table name: customer_credits
#
#  id                        :integer          not null, primary key
#  profile_id :integer          not null
#  amount                    :decimal(, )      not null
#  refundable_amount         :decimal(, )      not null
#  final_balance             :decimal(, )      not null
#  final_refundable_balance  :decimal(, )      not null
#  credit_value              :decimal(, )      not null
#  payment_method            :string           not null
#  transaction_origin         :string           not null
#  deleted_at                :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

FactoryGirl.define do
  factory :customer_credit do
    profile

    trait :hospitality do
      amount 10
      refundable_amount 0
      credit_value 1
      payment_method "none"
      transaction_origin "offline"
    end

    trait :online do
      amount 20
      refundable_amount 20
      credit_value 1
      payment_method { %w(cash card paypal).sample }
      transaction_origin "online"
    end

    trait :onsite do
      amount 15
      refundable_amount 5
      credit_value 1
      payment_method { %w(cash card paypal).sample }
      transaction_origin "offline"
    end

    after :create do |customer_credit|
      final_balance = CustomerCredit.select("sum(amount) as final_balance")
                                    .group("customer_credits.created_in_origin_at")
                                    .find_by(profile: customer_credit.profile).final_balance.to_i

      customer_credit.final_balance = final_balance
      final_refundable = CustomerCredit.select("sum(refundable_amount) as final_refundable_balance")
                                       .group("customer_credits.created_in_origin_at")
                                       .find_by(profile: customer_credit.profile)
                                       .final_refundable_balance.to_i
      customer_credit.final_refundable_balance = final_refundable
      customer_credit.save
    end

    factory :customer_credit_hospitality, traits: [:hospitality]
    factory :customer_credit_online, traits: [:online]
    factory :customer_credit_onsite, traits: [:onsite]
  end
end
