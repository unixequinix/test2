class Api::V1::CreditSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :description, :value, :standard, :currency

  def description
    object.catalog_item.description
  end

  def name
    object.catalog_item.name
  end
end
