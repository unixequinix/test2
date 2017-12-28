module Api
  module V1
    class CredentialSerializer < ActiveModel::Serializer
      attributes :reference, :type, :redeemed, :banned

      def type
        object.class.name.downcase
      end
    end
  end
end
