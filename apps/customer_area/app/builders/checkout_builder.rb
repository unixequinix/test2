class CheckoutBuilder
  def initialize(current_event)
    @current_event = current_event
    @preevent_products = PreeventProduct.where(event_id: current_event)
  end

  def keys_sortered
    %w(Credit Voucher CredentialType Pack)
  end

  def preevent_products_sortered
    @sortered_products_storage = Hash[keys_sortered.map { |key| [key, []] }]
    @preevent_products.each do |preevent_product|
      next unless preevent_product.online
      category = is_a_pack?(preevent_product) ? "Pack" : nil
      add_product_to_storage(preevent_product, category)
    end
    @sortered_products_storage.values.flatten
  end

  private

  def add_product_to_storage(preevent_product, new_category)
    category = new_category || get_product_category(preevent_product)
    @sortered_products_storage[category] << preevent_product
  end

  def get_product_category(preevent_product)
    preevent_product.preevent_items.first.purchasable_type
  end

  def is_a_pack?(preevent_product)
    preevent_product.preevent_items.count > 1
  end
end
