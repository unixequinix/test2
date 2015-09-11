# == Schema Information
#
# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string
#  tag_serial_number :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  deleted_at        :datetime
#  event_id          :integer          not null
#

FactoryGirl.define do
  factory :gtag do
    event
    tag_uid { Faker::Lorem.characters(10) }
    tag_serial_number { Faker::Lorem.characters(10) }
  end
end
