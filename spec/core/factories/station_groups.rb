FactoryGirl.define do
  factory :station_group do
    name { "#{rand(100)} a name" }
    icon_slug { "#{rand(100)} slug" }
  end
end
