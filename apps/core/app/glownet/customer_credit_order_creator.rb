class CustomerCreditOrderCreator < CustomerCreditCreator
  # TODO: refactor hard
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

  # TODO: This is temporary workaruond until final release
  def create_customer_credit_for_single_credits(order, order_item)
    params = {
      profile: order.profile,
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

  def create_customer_credit_for_pack(order, order_item, credit_item, refundable)
    amount = credit_item.total_amount * order_item.amount
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
