class Api::V2::RefundSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :fee, :field_a, :field_b, :money

  has_one :customer, serializer: Api::V2::Simple::CustomerSerializer
end
