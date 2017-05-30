class Api::V1::OperatorPermissionSerializer < ActiveModel::Serializer
  attributes :id, :role, :group, :station_id, :name
end
