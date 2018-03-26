FactoryBot.define do
  factory :device do
    app_id { SecureRandom.hex(8).upcase }
    mac { SecureRandom.hex(8).upcase }
    serial { SecureRandom.hex(8).upcase }
    imei { SecureRandom.hex(8).upcase }
    team
    device_model "Famoco"
    android_version "3.4.5.6"
    manufacturer "Famoco"
  end
end
