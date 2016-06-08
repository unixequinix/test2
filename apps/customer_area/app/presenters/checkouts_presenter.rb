class CheckoutsPresenter
  def initialize(current_event, current_profile)
    @event = current_event
    @profile = current_profile
    param = StationParameter.joins(:station).where(stations: { event_id: current_event,
                                                               category: "customer_portal" })
    @catalog_items =
      CatalogItem.joins(:station_catalog_items, station_catalog_items: :station_parameter)
                 .select("catalog_items.*, station_catalog_items.price")
                 .where.not(id: infinite_entitlements_ids)
                 .where(station_parameters: param)
                 .includes(:event)
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

  def catalog_items_hash
    @catalog_items.hash_sorted
  end

  def catalog_items
    catalog_items_hash.values.flatten
  end

  private

  def infinite_entitlements_ids
    @profile.infinite_entitlements_purchased
  end
end
