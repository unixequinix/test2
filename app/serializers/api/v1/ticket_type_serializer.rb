module Api
  module V1
    class TicketTypeSerializer < ActiveModel::Serializer
      attributes :id, :name, :catalog_item_id, :catalog_item_type, :company_id
      attribute :company, key: :company_name
      attribute :company_code, key: :ticket_type_ref

      def company_id
        1
      end

      def catalog_item_type
        object.catalog_item.type
      end
    end
  end
end
