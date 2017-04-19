class Api::V2::AccessSerializer < ActiveModel::Serializer
  attributes :id, :name, :mode
end
