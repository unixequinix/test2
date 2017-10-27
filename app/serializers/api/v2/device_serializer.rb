module Api::V2
  class DeviceSerializer < ActiveModel::Serializer
    attributes :id, :mac, :asset_tracker
  end
end
