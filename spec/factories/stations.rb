# == Schema Information
#
# Table name: stations
#
#  address            :string
#  category           :string
#  group              :string
#  location           :string           default("")
#  name               :string           not null
#  official_name      :string
#  position           :integer
#  registration_num   :string
#  reporting_category :string
#
# Indexes
#
#  index_stations_on_event_id          (event_id)
#  index_stations_on_station_event_id  (station_event_id)
#
# Foreign Keys
#
#  fk_rails_4d84bcb9bb  (event_id => events.id)
#

FactoryGirl.define do
  factory :station do
    event
    sequence(:name) { |n| "Station #{n}" }
    category "customer_portal"
    group "access"
  end
end
