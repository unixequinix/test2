class CheckoutsPresenter
  attr_reader :preevent_products

  def initialize(current_event)
    @event = current_event
    @preevent_products = PreeventProduct.online_preevent_products_hash_sorted(current_event)
  end

  def draw_product(preevent_product)
    return credit_partial if is_unitary_credit(preevent_product)
    standard_partial
  end

  def is_unitary_credit(preevent_product)
    preevent_product.preevent_items_count == 1 &&
    preevent_product.preevent_items.first.purchasable_type == "Credit"
  end

  def credit_partial
    "credit"
  end

  def standard_partial
    "preevent_product"
  end
end
