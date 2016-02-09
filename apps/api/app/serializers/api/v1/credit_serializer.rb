module Api
  module V1
    class CreditSerializer < Api::V1::BaseSerializer
      attributes :id, :value, :standard, :currency
    end
  end
end
