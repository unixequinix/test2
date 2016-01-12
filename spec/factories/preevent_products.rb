# == Schema Information
#
# Table name: preevent_products
#
#  id         :integer          not null, primary key
#  event_id   :integer
#  name       :string
#  online     :boolean          default(FALSE), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :preevent_product do
    name { Faker::Number.between(1, 20) }
    online { [true,false].sample }
    event
  end
end
