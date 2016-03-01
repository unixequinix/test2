class CheckoutForm
  include ActiveModel::Model

  def initialize(customer_event_profile)
    @customer_event_profile = customer_event_profile
    @order = Order.new
  end

  def submit(params, catalog_items_fetched)
    if persist(params, catalog_items_fetched)
      true
    else
      false
    end
  end

  attr_reader :order

  private

  def persist(params, catalog_items_fetched)
    @order.customer_event_profile = @customer_event_profile
    @order.generate_order_number!
    catalog_items_fetched.each do |catalog_item|
      amount = params[:catalog_items][catalog_item.id.to_s].to_i
      next unless !amount.nil? && amount > 0
      @order.order_items << OrderItem.new(
        catalog_item_id: catalog_item.id,
        amount: amount,
        total: amount * catalog_item.price
      )
    end
    @order.save ? true : false
  end
end
