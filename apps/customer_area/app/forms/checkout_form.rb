class CheckoutForm
  include ActiveModel::Model

  def initialize(customer_event_profile)
    @customer_event_profile = customer_event_profile
    @order = Order.new
  end

  def submit(params)
    if persist(params)
      true
    else
      false
    end
  end

  attr_reader :order

  private

  def persist(params)
    @order.customer_event_profile = @customer_event_profile
    @order.generate_order_number!
    Credit.all.each do |credit|
      amount = params[:credits]["#{credit.id}"].to_i
      next unless !amount.nil? && amount > 0
      @order.order_items << OrderItem.new(
        preevent_product_id: credit.preevent_product.id,
        amount: amount,
        total: amount * credit.preevent_product.rounded_price
      )
    end
    @order.save ? true : false
  end
end
