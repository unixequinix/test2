FactoryBot.define do
  factory :device do
    mac { SecureRandom.hex(8).upcase }
  end
end
