class Api::V2::Simple::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :anonymous
end
