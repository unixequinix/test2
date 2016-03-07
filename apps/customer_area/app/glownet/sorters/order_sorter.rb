class Sorters::OrderSorter < Sorters::ItemSorter

  def initialize(items)
    @keys = %w(Voucher Access)
    @hash = build_hash_of_arrays
    @items = items.map do |item|
      Sorters::FakeCatalogItem.new(
        product_name: item.product_name,
        catalogable_type: item.catalogable_type,
        catalog_item_id: item.catalog_item_id,
        total_amount: item.total_amount
      )
    end
  end

  def sort
    build_hash
    remove_empty_categories
    sort_by_criteria(:total_amount)
  end

  def disaggregated_sort
    build_hash
    disaggregate_packs
    remove_empty_categories
    sort_by_criteria(:total_amount)
  end

  def disaggregate_packs
    packs_included_in_order.each do |pack_reference|
      pack_catalog_items(pack_reference).each do |pack_catalog_item|
        catalog_item = CatalogItem.find(pack_catalog_item.catalog_item_id)
        if @keys.include? catalog_item.catalogable_type
          item_amount = pack_reference.total_amount * pack_catalog_item.amount
          update_sorting_hash(catalog_item, item_amount)
        end
      end
    end
  end

  private

  def packs_included_in_order
    @items.select { |item| item.catalogable_type == "Pack" }
  end

  def pack_catalog_items(pack_reference)
    PackCatalogItem.where(
        pack_id: CatalogItem.find(pack_reference.catalog_item_id).catalogable_id)
  end

  def update_sorting_hash(catalog_item, item_amount)
    catalog_item_category_array = @hash[catalog_item.catalogable_type]
    catalog_item_found = catalog_item_category_array.find do |item|
      item.catalog_item_id == catalog_item.id
    end

    if catalog_item_found.present?
      catalog_item_found.total_amount += item_amount
    else
      add_new_item_to_sorting_hash(catalog_item, item_amount)
    end
  end

  def add_new_item_to_sorting_hash(catalog_item, item_amount)
    @hash[catalog_item.catalogable_type].push(
      Sorters::FakeCatalogItem.new(
        total_amount: item_amount,
        product_name: catalog_item.name
      )
    )
  end
end