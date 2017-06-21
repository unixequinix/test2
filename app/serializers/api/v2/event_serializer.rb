class Api::V2::EventSerializer < ActiveModel::Serializer
  attributes :name, :slug, :logo, :background, :currency, :state, :open_topups, :open_refunds, :credit

  def credit
    Api::V2::CreditSerializer.new(object.credit)
  end
end
