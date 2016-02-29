class CheckoutsPresenter
  attr_reader :catalog_items_hash

  def initialize(current_event)
    @event = current_event
    @catalog_items =
      CatalogItem.joins(:station_catalog_items, station_catalog_items: :station_parameter)
                 .select("catalog_items.*, station_catalog_items.price")
                 .where(station_parameters:
                       { id: StationParameter.joins(station: :station_type)
                                             .where(
                                               stations: { event_id: current_event },
                                               station_types: { name: "customer_portal" }
                                              )})
    @catalog_items_hash = @catalog_items.hash_sorted(keys_sorted)
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

  def keys_sorted
    %w(Credit Voucher Access Pack)
  end
end

