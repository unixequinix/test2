class Api::V1::StationSerializer < Api::V1::BaseSerializer
  attributes :id, :type, :name

  def type
    object.station_type.name
  end
end
