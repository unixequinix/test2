module Api
  module V1
    class PackSerializer < ActiveModel::Serializer
      attributes :id, :name, :items

      def items
        object.catalog_items.select(:id, :type, :amount).map(&:attributes)
      end
    end
  end
end
