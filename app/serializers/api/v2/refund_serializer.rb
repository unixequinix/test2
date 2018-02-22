module Api::V2
  class RefundSerializer < ActiveModel::Serializer
    attributes :id, :customer_id, :status, :fields, :credit_base, :credit_fee, :money_base, :money_fee
  end
end
