# == Schema Information
#
# Table name: refunds
#
#  amount      :decimal(8, 2)    not null
#  fee         :decimal(8, 2)
#  field_a     :string
#  field_b     :string
#  money       :decimal(8, 2)
#  status      :string
#
# Indexes
#
#  index_refunds_on_customer_id  (customer_id)
#
# Foreign Keys
#
#  fk_rails_6a4a43dcc1  (customer_id => customers.id)
#

FactoryGirl.define do
  factory :refund do
    customer
    sequence(:amount)
    sequence(:fee)
    status "started"
    field_a "ES91 2100 0418 4502 0005 1332"
    field_b "BBVAESMMXXX"
  end
end
