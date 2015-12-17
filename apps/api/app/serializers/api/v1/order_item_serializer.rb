module Api
  module V1
    class OrderItemSerializer < Api::V1::BaseSerializer
      attributes :online_product, :amount, :total
      has_one :online_product
    end
  end
end
