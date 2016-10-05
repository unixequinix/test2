FactoryGirl.define do
  factory :claim do
    profile { create(:profile) }
    gtag { create(:gtag) }
    number { Time.zone.now.strftime("%H%M%L%y%m%d").to_i.to_s(16) }
    total { rand(100) }
    service_type "paypal"
    fee 0
    minimum 1
  end
end
