module Api
  module V1
    class TicketSerializer < ActiveModel::Serializer
      attributes :reference, :redeemed, :banned, :catalog_item_id, :ticket_type_id, :customer, :purchaser_first_name, :purchaser_last_name, :purchaser_email # rubocop:disable Metrics/LineLength

      def catalog_item_id
        object.ticket_type&.catalog_item_id
      end

      def customer
        CustomerSerializer.new(object.customer).as_json if object.customer
      end
    end
  end
end
