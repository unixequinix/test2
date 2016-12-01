# == Schema Information
#
# Table name: credits
#
#  id         :integer          not null, primary key
#  standard   :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#  value      :decimal(8, 2)    default(1.0), not null
#  currency   :string           not null
#

FactoryGirl.define do
  factory :credit do |_param|
    event
    sequence(:name) { |n| "CRD #{n}" }
    initial_amount 0
    step 1
    max_purchasable 1
    min_purchasable 0
    value 1
  end
end
