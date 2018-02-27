module Api
  module V1
    class TicketTypeSerializer < ActiveModel::Serializer
      attributes :id, :name, :company_id, :company_name, :ticket_type_ref, :catalog_item_id, :catalog_item_type

      def company_name
        object.company.name
      end

      def ticket_type_ref
        object.company_code
      end

      def catalog_item_type
        object.catalog_item.type
      end
    end
  end
end
