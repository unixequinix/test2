module Api
  module V1
    class CredentialSerializer < ActiveModel::Serializer
      attributes :reference, :type, :redeemed, :banned, :ticket_type_id

      def type
        object.class.name.downcase
      end
    end
  end
end
