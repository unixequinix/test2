class Api::V2::Simple::GtagSerializer < ActiveModel::Serializer
  attributes :id, :tag_uid, :banned, :redeemed, :active, :credits, :refundable_credits, :final_balance, :final_refundable_balance, :customer_id, :ticket_type_id # rubocop:disable Metrics/LineLength
end
