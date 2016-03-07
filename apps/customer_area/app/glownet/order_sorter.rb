class OrderSorter < ItemSorter

  def initialize(items)
    @keys = %w(Voucher Access)
    @hash = build_hash_of_arrays
    @items = items.map do |item|
      FakeCatalogItem.new(
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
    packs = @items.select { |item| item.catalogable_type == "Pack" }
    packs.each do |pack_reference|
      pack_catalog_items = PackCatalogItem.where(
        pack_id: CatalogItem.find(pack_reference.catalog_item_id).catalogable_id)
      pack_catalog_items.each do |pack_catalog_item|
        catalog_item = CatalogItem.find(pack_catalog_item.catalog_item_id)
        if @keys.include? catalog_item.catalogable_type
          array = @hash[catalog_item.catalogable_type]
          found = array.any? { |it| it.catalog_item_id == catalog_item.id }
          if found
            h = @hash[catalog_item.catalogable_type].find { |it| it.catalog_item_id == catalog_item.id }
            h.total_amount += pack_reference.total_amount * pack_catalog_item.amount
          else
            @hash[catalog_item.catalogable_type].push(
              FakeCatalogItem.new(
                total_amount: pack_reference.total_amount * pack_catalog_item.amount,
                product_name: catalog_item.name
              )
            )
          end
        end
      end
    end
    @hash
  end

end