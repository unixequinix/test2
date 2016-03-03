class Api::V1::AccessSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :unlimited, :position

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

  def unlimited
    object.entitlement.unlimited
  end

  def position
    object.entitlement.memory_position
  end
end
