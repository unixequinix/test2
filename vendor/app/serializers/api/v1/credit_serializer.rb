module Api
  module V1
    class CreditSerializer < ActiveModel::Serializer
      attributes :id, :name, :value, :currency, :currency_symbol, :type, :position, :spending_order, :max_balance
      attribute :symbol, key: :credit_symbol

      def currency
        object.event.currency
      end

      def currency_symbol
        object.event.currency_symbol
      end
    end
  end
end
