class Api::V1::CreditSerializer < Api::V1::BaseSerializer
  attributes :id, :value, :standard, :currency

  def attributes(*args)
    hash = super
    hash[:description] = item_description if item_description
    hash
  end

  def item_description
    object.catalog_item.description
  end
end
