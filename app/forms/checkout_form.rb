class CheckoutForm
  include ActiveModel::Model

  def initialize(customer)
    @customer = customer
    @order = Order.new
  end

  def submit(params)
    if valid?
      persist(params)
      true
    else
      false
    end
  end

  def order
    @order
  end

  private

  def persist(params)
    @order.customer = @customer
    @order.generate_order_number!
    Credit.all.each do |credit|
      amount = params[:credits]["#{credit.id}"].to_i
      if !amount.nil? && amount > 0
        @order.order_items << OrderItem.new(online_product_id: credit.online_product.id, amount: amount, total: amount * credit.online_product.price)
      end
    end
    @order.save!
  end
end