module Api::V2
  class Simple::GtagSerializer < ActiveModel::Serializer
    attributes :id, :tag_uid, :banned, :redeemed, :active, :consistent, :credits, :refundable_credits, :final_balance, :final_refundable_balance, :customer_id, :ticket_type_id # rubocop:disable Metrics/LineLength

    def consistent
      object.valid_balance?
    end
  end
end
