module Api
  module V1
    class TicketTypeSerializer < ActiveModel::Serializer
      attributes :id, :name, :ticket_type_ref, :catalog_item_id, :catalog_item_type
      attribute :company, key: :company_name

      def ticket_type_ref
        object.company_code
      end

      def catalog_item_type
        object.catalog_item.type
      end
    end
  end
end
