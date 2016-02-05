module Api
  module V1
    class PreeventProductSerializer < Api::V1::BaseSerializer
      attributes :id, :name

      def attributes(*args)
        hash = super
        hash[:credits] = credits if credits.present?
        hash[:credentials] = credentials if credentials.present?
        hash
      end

      def credentials
        selected = object.preevent_product_items.select do |item|
          item.preevent_item.purchasable_type == "CredentialType"
        end
        selected.map(&:id)
      end

      def credits
        selected = object.preevent_product_items.select do |item|
          item.preevent_item.purchasable_type == "Credit"
        end
        selected.map(&:amount).inject(:+)
      end
    end
  end
end
