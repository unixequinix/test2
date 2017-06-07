class Api::V2::EventSerializer < ActiveModel::Serializer
  attributes :name, :slug, :logo, :background, :currency, :credit_name, :state, :open_topups, :open_refunds

  def credit_name
    object.credit.name
  end
end
