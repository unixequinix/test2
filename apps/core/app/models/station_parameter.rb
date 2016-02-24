class StationParameter < ActiveRecord::Base
  # Associations
  belongs_to :station
  belongs_to :station_parametable, polymorphic: true, touch: true

  # Validations
  validates :station, presence: true
end
