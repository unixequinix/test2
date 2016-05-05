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
      final_balance = CustomerCredit.select("sum(amount) as final_balance, sum(refundable_amount)" \
                      "as final_refundable_balance")
                      .where(profile: customer_credit.profile)[0]
                      .final_balance
                      .to_i

      customer_credit.final_balance = final_balance
      customer_credit.final_refundable_balance = CustomerCredit
        .select("sum(amount) as final_balance, sum(refundable_amount) as final_refundable_balance")
        .where(profile: customer_credit.profile)[0]
        .final_refundable_balance.to_i
      customer_credit.save
    end

    factory :customer_credit_hospitality, traits: [:hospitality]
    factory :customer_credit_online, traits: [:online]
    factory :customer_credit_onsite, traits: [:onsite]
  end
end
