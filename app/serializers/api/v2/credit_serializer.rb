class Api::V2::CreditSerializer < ActiveModel::Serializer
  attributes :id, :name, :value
end
