FactoryGirl.define do
  factory :device_transaction do
    action "device_initialization"
    sequence(:device_uid) { |n| "DEVICE##{n}" }
  end
end
