class CheckoutsPresenter
  attr_reader :catalog_items_hash

  def initialize(current_event)
    @event = current_event
    @catalog_item
    @catalog_items_hash = CatalogItem.catalog_items_hash_sorted(current_event)
  end

  def draw_product(catalog_item)
    return credit_partial if unitary_credit?(catalog_item)
    standard_partial
  end

  def unitary_credit?(catalog_item)
      catalog_item.catalogable_type == "Credit"
  end

  def credit_partial
    "credit"
  end

  def standard_partial
    "catalog_item"
  end

  def catalog_items
    @catalog_items_hash.values.flatten
  end
end
