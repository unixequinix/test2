class Api::V2::CompanySerializer < ActiveModel::Serializer
  attributes :id, :name, :access_token

  has_many :ticket_types
end
