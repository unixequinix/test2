module Api
  module V1
    class DeviceSerializer < ActiveModel::Serializer
      attributes :id, :asset_tracker, :imei, :mac, :serial, :manufacturer, :device_model, :android_version, :events

      def events
        object.events_for_device.map { |e| EventSerializer.new(e, serializer_params: { device: object }) }
      end
    end
  end
end
