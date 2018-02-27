module Api::V2
  class EventSerializer < ActiveModel::Serializer
    attributes :name, :slug, :logo, :background, :currency, :state, :open_topups, :open_refunds, :every_topup_fee
    attribute :online_initial_topup_fee, key: :initial_fee
    attribute :credit

    def credit
      Api::V2::CreditSerializer.new(object.credit)
    end
  end
end
