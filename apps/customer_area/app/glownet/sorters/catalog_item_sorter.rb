class Sorters::CatalogItemSorter < Sorters::ItemSorter
  # Formats
  LIST = :list
  HASH = :hash

  FORMATS = [LIST, HASH]

  def initialize(items)
    @keys = %w(Credit Voucher Access Pack)
    super(items)
  end

  def sort(format:)
    format = FORMATS.include?(format) ? format : HASH
    build_hash
    remove_empty_categories
    format == HASH ? sort_by_criteria(:price) : sort_by_criteria(:price).values.flatten
  end

end
