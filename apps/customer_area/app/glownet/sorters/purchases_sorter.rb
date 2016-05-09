class Sorters::PurchasesSorter < Sorters::ItemSorter
  # Formats
  LIST = :list
  HASH = :hash

  FORMATS = [LIST, HASH].freeze

  def initialize(items, keys = nil)
    @keys = keys || %w(Voucher Access)
    @hash = build_hash_of_arrays
    @items = items.map do |item|
      Sorters::FakeCatalogItem.new(
        product_name: item.name,
        catalogable_type: item.catalogable_type,
        catalogable_id: item.catalogable_id,
        catalog_item_id: item.id,
        total_amount: item.total_amount
      )
    end
  end

  def sort(format:, itemized: true)
    format = FORMATS.include?(format) ? format : HASH
    build_hash
    itemize_packs if itemized
    remove_empty_categories
    final_collection = sort_by_criteria(:total_amount)
    format == HASH ? final_collection : final_collection.values.flatten
  end

  private

  def itemize_packs
    packs_included_in_purchase.each do |pack_reference|
      pack_catalog_items(pack_reference).each do |pack_catalog_item|
        catalog_item = CatalogItem.find(pack_catalog_item.catalog_item_id)
        if @keys.include? catalog_item.catalogable_type
          item_amount = pack_reference.total_amount * pack_catalog_item.amount
          update_sorting_hash(catalog_item, item_amount)
        end
      end
    end
  end

  def packs_included_in_purchase
    @items.select { |item| item.catalogable_type == "Pack" }
  end

  def pack_catalog_items(pack_reference)
    PackCatalogItem.where(pack_id: CatalogItem.find(pack_reference.catalog_item_id).catalogable_id)
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
