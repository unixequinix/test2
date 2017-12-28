module Api
  module V1
    class GtagSerializer < ActiveModel::Serializer
      attributes :reference, :redeemed, :banned, :customer

      def customer
        CustomerSerializer.new(object.customer).as_json if object.customer
      end
    end
  end
end
