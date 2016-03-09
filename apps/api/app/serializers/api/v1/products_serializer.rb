class Api::V1::ProductsSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :is_alcohol

  def attributes(*args)
    hash = super
    hash[:description] = item_description if item_description
    hash
  end

  def item_description
    object.catalog_item.description
  end

  def name
    object.catalog_item.name
  end
end
