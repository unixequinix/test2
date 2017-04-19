class Api::V2::GtagSerializer < ActiveModel::Serializer
  attributes :id, :tag_uid, :banned, :format, :active, :credits, :refundable_credits, :final_balance, :final_refundable_balance, :redeemed

  has_one :ticket_type
  has_one :customer, serializer: Api::V2::Simple::CustomerSerializer
end
