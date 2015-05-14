module Api
  module V1
    class OrderSerializer < Api::V1::BaseSerializer
      attributes :number, :state, :completed_at, :total, :credits_total
      has_one :customer
      has_many :order_items

      def state
        object.aasm_state
      end
    end
  end
end
