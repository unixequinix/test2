FactoryBot.define do
  factory :device do
    team
    mac { SecureRandom.hex(8).upcase }
  end
end
