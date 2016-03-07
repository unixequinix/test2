class Sorters::CatalogItemSorter < Sorters::ItemSorter
  def initialize(items)
    @keys = %w(Credit Voucher Access Pack)
    super(items)
  end

  def sort
    build_hash
    remove_empty_categories
    sort_by_criteria(:price)
  end
end