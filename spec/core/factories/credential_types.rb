# == Schema Information
#
# Table name: credential_types
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

FactoryGirl.define do
  factory :credential_type do
    after(:build) do |credential|
      credential.preevent_item ||= build(:preevent_item_credential, purchasable: credential)
    end
  end
end
