module Api
  module V1
    class PreeventProductSerializer < Api::V1::BaseSerializer
      attributes :id, :name, :credentials, :credits

      # TODO: Add credentials and credits
      def credentials
        [2, 5]
      end

      def credits
        selected = object.preevent_product_items.select{ |item| item.preevent_item.purchasable_type == "Credit" }
        selected.map(&:amount).inject(:+)
      end
    end
  end
end
