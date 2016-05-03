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

  def single_customer_credit(order, order_item)
    CustomerCredit.create(
      customer_event_profile: order.customer_event_profile,
      transaction_origin: CustomerCredit::CREDITS_PURCHASE,
      payment_method: "none",
      credit_value: order_item.catalog_item.catalogable.value,
      amount: order_item.amount,
      refundable_amount: order_item.amount
    }
    credits = order.profile.customer_credits
    calculate_finals(params, credits, order_item.amount, order_item.amount)
    CustomerCredit.create(params)
  end


  def pack_customer_credit(order, order_item, credit_item, refundable)
    params = {
      profile: order.profile,
      transaction_origin: CustomerCredit::CREDITS_PURCHASE,
      payment_method: "none",
      credit_value: credit_item.value,
      amount: amount,
      refundable_amount: refundable
    }
    create_credit(order.profile, params)
  end
end
