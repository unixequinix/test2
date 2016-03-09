class Api::V1::VouchersSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :position, :infinite

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
