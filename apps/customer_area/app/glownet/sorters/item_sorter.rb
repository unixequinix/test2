class Sorters::ItemSorter
  def initialize(items)
    @items = items
    @hash = build_hash_of_arrays
  end

  def build_hash
    @items.each_with_object(@hash) do |catalog_item, acum|
      category = catalog_item.catalogable_type
      acum[category] << catalog_item  if @keys.include? catalog_item.catalogable_type
    end
  end

  def remove_empty_categories
    @hash.delete_if { |_k, v| v.blank? }
  end

  def sort_by_criteria(criteria)
    @hash.each do |_k, v|
      v.sort! { |x, y| x.send(criteria) <=> y.send(criteria) }
    end
  end

  def build_hash_of_arrays
    Hash[@keys.map { |key| [key, []] }]
  end
end
