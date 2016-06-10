class CustomerCreditOrderCreator < CustomerCreditCreator
  # TODO: refactor hard
  def save(order)
    order.order_items.each do |order_item|
      single_customer_credit(order, order_item) && next if order_item.single_credits?
      next unless order_item.pack_with_credits?

      pack = order_item.catalog_item.catalogable
      pack.credits.each do |credit_item|
        refundable_amount = refundable(pack, order_item, credit_item)
        pack_customer_credit(order, order_item, credit_item, refundable_amount)
      end
    end
  end

  private

  # TODO: paypal as a payment option is wrong. it should be the payment gateway being used
  def single_customer_credit(order, order_item)
    params = {
      payment_method: "paypal",
      transaction_type: "online_topup",
      credit_value: order_item.catalog_item.catalogable.value,
      amount: order_item.amount,
      refundable_amount: order_item.amount
    }
    create_credit(order.profile, params)
  end

  def pack_customer_credit(order, order_item, credit_item, refundable_amount)
    params = {
      payment_method: "paypal",
      transaction_type: "online_topup",
      credit_value: credit_item.value,
      amount: credit_item.total_amount * order_item.amount,
      refundable_amount: refundable_amount
    }
    create_credit(order.profile, params)
  end

  def refundable(pack, order_item, credit_item)
    if pack.only_credits_pack?
      [credits_by_money_payed(order_item, credit_item),
       credits_included_in_pack(order_item, credit_item)].min
    else
      0
    end
  end

  def credits_by_money_payed(order_item, credit_item)
    order_item.total / credit_item.value
  end

  def credits_included_in_pack(order_item, credit_item)
    order_item.amount * credit_item.total_amount
  end
end
