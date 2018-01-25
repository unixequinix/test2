module Api::V2
  class RefundSerializer < ActiveModel::Serializer
    attributes :id, :amount, :status, :fee, :fields, :customer_id
  end
end
