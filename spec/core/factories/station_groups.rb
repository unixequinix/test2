FactoryGirl.define do
  factory :station_group do
    name { %w(access monetary glownet touchpoint event_management).sample }
    icon_slug { %w(A B C D E).sample }
  end
end
