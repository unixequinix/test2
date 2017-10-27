module Api::V2
  class EventSeriesSerializer < ActiveModel::Serializer
    attributes :id, :name

    has_many :events, serializer: EventSerializer
  end
end
