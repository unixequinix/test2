module Api::V2
  class GtagSerializer < ActiveModel::Serializer
    attributes :id, :name
  end
end
