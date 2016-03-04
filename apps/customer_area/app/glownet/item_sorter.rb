class ItemSorter
  def initialize(items)
    @items = items
    @hash = Hash[@keys.map { |key| [key, []] }]
  end

  def build_hash
    @items.each_with_object(@hash) do |catalog_item, acum|
      acum[catalog_item.catalogable_type] << catalog_item if @keys.include? catalog_item.catalogable_type
    end
  end

  def remove_empty_categories
    @hash.delete_if { |_k, v| v.blank? }
  end

  def sort_by_criteria(criteria)
    @hash.each do |_k, v|
      v.sort! { |x, y| x.send(criteria) <=> y.send(criteria)}
    end
  end

end