class OrderSorter < ItemSorter

  def initialize(items)
    @keys = %w(Voucher Access)
    super(items)
  end

  def sort
    build_hash
    remove_empty_categories
    sort_by_criteria(:total_amount)
  end
end