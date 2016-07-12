FactoryGirl.define do
  factory :device do
    device_model { "Rand #{rand(100)}" }
    imei { SecureRandom.hex(8).upcase }
    mac { SecureRandom.hex(8).upcase }
    serial_number { SecureRandom.hex(8).upcase }
  end
end
