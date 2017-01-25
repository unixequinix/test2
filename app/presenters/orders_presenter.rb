class OrdersPresenter < BasePresenter
  def can_render?
    @customer.active_credentials? && orders.present?
  end

  def path
    "orders"
  end

  def orders
    @customer.orders.completed
  end
end
