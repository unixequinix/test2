module Api::V2
  class AccessSerializer < ActiveModel::Serializer
    attributes :id, :name, :mode
  end
end
