class CustomerCreditOrderCreator < CustomerCreditCreator
  def save(order)
    order.order_items.each do |order_item|
      case
      when order_item.single_credits?
        @customer_credit = create_customer_credit_for_single_credits(order, order_item)
      when order_item.pack_with_credits?
        pack = order_item.catalog_item.catalogable
        pack.credits.each do |credit_item|
          refundable = pack.only_credits_pack? ? order_item.total / credit_item.value : 0
          @customer_credit = create_customer_credit_for_pack(order,
                                                             order_item,
                                                             credit_item,
                                                             refundable)
        end
      end
    end
  end

  private

  def create_customer_credit_for_single_credits(order, order_item)
    CustomerCredit.create(
      customer_event_profile: order.customer_event_profile,
      transaction_origin: CustomerCredit::CREDITS_PURCHASE,
      payment_method: "none",
      credit_value: order_item.catalog_item.catalogable.value,
      amount: order_item.amount,
      refundable_amount: order_item.amount
    )
  end

  def create_customer_credit_for_pack(order, order_item, credit_item, refundable)
    params = {
      origin: CustomerCredit::CREDITS_PURCHASE,
      credit_value: credit_item.value,
      amount: credit_item.total_amount * order_item.amount,
      refundable_amount: refundable
    }
    create_credit(order.customer_event_profile, params)
  end
end
