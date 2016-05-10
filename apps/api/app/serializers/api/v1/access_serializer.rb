class Api::V1::AccessSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :mode, :position, :memory_length

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

  def mode
    object.entitlement.mode
  end

  def position
    object.entitlement.memory_position
  end

  def memory_length
    object.entitlement.memory_length.to_i
  end
end
