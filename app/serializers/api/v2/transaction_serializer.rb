class Api::V2::TransactionSerializer < ActiveModel::Serializer
  attributes :id, :gtag_id, :station_id, :credits, :refundable_credits, :final_balance, :final_refundable_balance, :sale_items
end