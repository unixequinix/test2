class StationType < ActiveRecord::Base
  belongs_to :station_group
  has_many :stations
end
