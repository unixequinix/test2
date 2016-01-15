module Api
  module V1
    class OrderSerializer < Api::V1::BaseSerializer
      attributes :number, :state, :completed_at, :total, :credits_total
      has_one :customer
      has_many :order_items

      def state
        object.aasm_state
      end

      def completed_at
        object.completed_at.in_time_zone.strftime('%y-%m-%d %H:%M:%S') if object.completed_at
      end
    end
  end
end
