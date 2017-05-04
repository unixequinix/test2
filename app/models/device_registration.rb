class DeviceRegistration < ActiveRecord::Base
  belongs_to :device
  belongs_to :event
end
