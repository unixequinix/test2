class Api::V1::StationGroupSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :icon_slug
  has_many :stations, serializer: Api::V1::StationSerializer

  def attributes(*args)
    hash = super
    hash
  end
end
