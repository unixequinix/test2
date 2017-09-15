class Api::V2::EventSeriesSerializer < ActiveModel::Serializer
  attributes :id, :name

  has_many :events, serializer: Api::V2::EventSerializer
end
