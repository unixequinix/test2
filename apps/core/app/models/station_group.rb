class StationGroup < ActiveRecord::Base
  has_many :station_types
  has_many :stations, through: :station_types
end
