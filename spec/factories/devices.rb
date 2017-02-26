FactoryGirl.define do
  factory :device do
    sequence(:device_model) { |n| "Model #{n}" }
    imei { SecureRandom.hex(8).upcase }
    mac { SecureRandom.hex(8).upcase }
    serial_number { SecureRandom.hex(8).upcase }
  end
end
