FactoryBot.define do
  factory :device_cache, class: 'DeviceCache' do
    category { "full" }
    app_version { "unknown" }
  end
end
