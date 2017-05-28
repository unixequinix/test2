FactoryGirl.define do
  factory :gtag do
    event
    tag_uid { SecureRandom.hex(8).upcase }
  end
end
