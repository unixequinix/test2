class Api::V2::DeviceSerializer < ActiveModel::Serializer
  attributes :id, :device_model, :imei, :mac, :serial_number, :asset_tracker
end
