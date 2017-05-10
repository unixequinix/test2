class Api::V2::DeviceSerializer < ActiveModel::Serializer
  attributes :id, :mac, :asset_tracker
end
