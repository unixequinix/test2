# == Schema Information
#
# Table name: gtags
#
#  id                :integer          not null, primary key
#  tag_uid           :string
#  tag_serial_number :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

FactoryGirl.define do
  factory :gtag do
    tag_uid 'TagUID'
    tag_serial_number { Faker::Number.number(10) }
  end
end
