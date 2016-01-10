# == Schema Information
#
# Table name: credential_types
#
#  id         :integer          not null, primary key
#  position   :integer          default(0), not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :credential_type do
    position { Faker::Number.between(1, 20) }
  end
end
