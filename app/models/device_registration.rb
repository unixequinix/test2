class DeviceRegistration < ApplicationRecord
  belongs_to :device
  belongs_to :event
end
