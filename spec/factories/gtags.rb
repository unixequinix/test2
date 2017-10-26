FactoryBot.define do
  factory :gtag do
    event
    tag_uid { SecureRandom.hex(7).upcase }
  end
end
