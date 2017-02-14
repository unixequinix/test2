class Api::V1::CredentialSerializer < ActiveModel::Serializer
  attributes :reference, :type, :redeemed, :banned

  def type
    object.class.name.downcase
  end
end
