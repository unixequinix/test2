class CheckoutForm
  include ActiveModel::Model

  def initialize(customer_event_profile)
    @customer_event_profile = customer_event_profile
    @order = Order.new
  end

  def submit(params, preevent_products_fetched)
    if persist(params, preevent_products_fetched)
      true
    else
      false
    end
  end

  attr_reader :order

  private

  def persist(params, preevent_products_fetched)
    @order.customer_event_profile = @customer_event_profile
    @order.generate_order_number!
    preevent_products_fetched.find(params[:preevent_products].keys).each do |preevent_product|
      amount = params[:preevent_products][preevent_product.id.to_s].to_i
      next unless !amount.nil? && amount > 0
      @order.order_items << OrderItem.new(
        preevent_product_id: preevent_product.id,
        amount: amount,
        total: amount * preevent_product.rounded_price
      )
    end
    @order.save ? true : false
  end
end
