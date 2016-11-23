FactoryGirl.define do
  factory :device_transaction do
    action "device_initialization"
    device_uid { "DEVICE##{rand(100)}" }
  end
end
