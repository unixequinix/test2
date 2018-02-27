module Api::V2
  class GtagSerializer < ActiveModel::Serializer
    attributes :id, :tag_uid, :format, :banned, :active, :redeemed, :consistent, :credits, :virtual_credits, :final_balance, :final_virtual_balance

    has_one :ticket_type
    has_one :customer, serializer: Simple::CustomerSerializer

    def consistent
      object.valid_balance?
    end
  end
end
