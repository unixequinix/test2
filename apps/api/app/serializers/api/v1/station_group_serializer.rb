class Api::V1::StationGroupSerializer < Api::V1::BaseSerializer
  attributes :station_group, :icon_slug
  has_many :stations, order: 'created_at DESC', serializer: Api::V1::StationSerializer

  def station_group
    object.name
  end
end
