class Api::V1::AccessSerializer < Api::V1::BaseSerializer
  # TODO: Add memory length
  attributes :id, :name, :infinite, :position

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

  def infinite
    object.entitlement.infinite
  end

  def position
    object.entitlement.memory_position
  end
end
