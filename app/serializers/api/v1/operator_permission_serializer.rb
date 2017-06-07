class Api::V1::OperatorPermissionSerializer < ActiveModel::Serializer
  attributes :id, :role, :group, :station_id, :name

  def station_id
    object.station&.station_event_id
  end
end
