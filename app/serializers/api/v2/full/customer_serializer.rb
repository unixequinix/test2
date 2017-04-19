class Api::V2::Full::CustomerSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :email, :phone, :birthdate, :phone, :postcode, :address, :city, :country, :gender
end
