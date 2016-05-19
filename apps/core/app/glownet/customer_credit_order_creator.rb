class CustomerCreditOrderCreator < CustomerCreditCreator
  # TODO: refactor hard
  def save(order)
    order.order_items.each do |order_item|
      single_customer_credit(order, order_item) && next if order_item.single_credits?
      next unless order_item.pack_with_credits?

      pack = order_item.catalog_item.catalogable
      pack.credits.each do |credit_item|
        refundable = pack.only_credits_pack? ? order_item.total / credit_item.value : 0
        pack_customer_credit(order, order_item, credit_item, refundable)
      end
    end
  end

  private

  # TODO: paypal as a payment option is wrong. it should be the payment gateway being used
  def single_customer_credit(order, order_item)
    params = {
      profile_id: order.profile.id,
      payment_method: "paypal",
      credit_value: order_item.catalog_item.catalogable.value,
      amount: order_item.amount,
      refundable_amount: order_item.amount,
      transaction_type: CustomerCredit::ONLINE_TOPUP
    }
    create_credit(order.profile, params)
  end

  def pack_customer_credit(order, order_item, credit_item, refundable)
    params = {
      profile_id: order.profile.id,
      transaction_origin: "online",
      payment_method: "paypal",
      credit_value: credit_item.value,
      amount: credit_item.total_amount * order_item.amount,
      refundable_amount: refundable,
      transaction_type: CustomerCredit::ONLINE_TOPUP
    }
    create_credit(order.profile, params)
  end
end
