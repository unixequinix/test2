# == Schema Information
#
# Table name: vouchers
#
#  id         :integer          not null, primary key
#  counter    :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :voucher do
    counter { Faker::Number.between(1, 20) }
    after :build do |voucher|
      voucher.preevent_item.build(:preevent_item, purchasable: voucher)
    end
  end
end
