class Api::V1::PackSerializer < Api::V1::BaseSerializer
  attributes :id, :name, :description, :accesses, :credits

  def description
    object.catalog_item.description
  end

  def name
    object.catalog_item.name
  end

  def accesses
    selected = object.pack_catalog_items.select do |pack_item|
      pack_item.catalog_item.catalogable_type == "Access"
    end
    selected.map { |a| { id: a.catalog_item.catalogable_id, amount: a.amount } }
  end

  # INFO: Right now it's the sum of all the Credits, ignoring Credit Types.
  def credits
    selected = object.pack_catalog_items.select do |pack_item|
      pack_item.catalog_item.catalogable_type == "Credit"
    end
    selected.map(&:amount).inject(:+)
  end
end
