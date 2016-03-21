class Api::V1::PackSerializer < Api::V1::BaseSerializer
  attributes :id, :name

  def attributes(*args)
    hash = super
    hash[:description] = item_description if item_description
    hash[:accesses] = accesses if accesses
    hash[:credits] = credits if credits
    hash
  end

  def item_description
    object.catalog_item.description
  end

  def name
    object.catalog_item.name
  end

  def accesses
    selected = object.pack_catalog_items.select do |pack_item|
      pack_item.catalog_item.catalogable_type == "Access"
    end
    selected.map { |a| {id: a.id, amount: a.amount} }
  end

  # INFO: Right now it's the sum of all the Credits, ignoring Credit Types.
  def credits
    selected = object.pack_catalog_items.select do |pack_item|
      pack_item.catalog_item.catalogable_type == "Credit"
    end
    selected.map(&:amount).inject(:+)
  end
end
