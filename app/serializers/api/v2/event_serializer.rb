class Api::V2::EventSerializer < ActiveModel::Serializer
  attributes :name, :slug, :logo, :background, :currency, :credit_name, :state

  def credit_name
    object.credit.name
  end
end
