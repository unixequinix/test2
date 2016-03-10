class CustomerCreditOrderCreator
  attr_reader :customer_credit

  def save(order)
    order.order_items.each do |order_item|
      @order_item =  order_item
      @event = order.customer_event_profile.event
      if order_item.credits?
        @customer_credit = CustomerCredit.new(
          customer_event_profile: order.customer_event_profile,
          transaction_origin: CustomerCredit::CREDITS_PURCHASE,
          payment_method: "none",
          credit_value: get_credit_value(@event),
          amount: @order_item.credits_included,
          refundable_amount: calculate_refundable_amount
        )
        calculate_balances
        @customer_credit.save if @customer_credit.valid?
      end
    end
  end

  def calculate_refundable_amount
    pack_with_unrefundable_credits? ? 0 : @order_item.total / get_credit_value(@event)
  end

  def calculate_balances
    balances = CustomerCredit
               .select("sum(amount) as final_balance,
                        sum(refundable_amount) as final_refundable_balance")
               .where(customer_event_profile: @customer_credit.customer_event_profile)[0]
    @customer_credit.final_balance =
      balances.final_balance.to_i + @customer_credit.amount
    @customer_credit.final_refundable_balance =
      balances.final_refundable_balance.to_i + @customer_credit.refundable_amount
  end

  def get_credit_value(event)
    catalog_item = @order_item.catalog_item
    if catalog_item.catalogable_type == "Pack"
      if catalog_item.catalogable.credits_pack?
        catalog_item.catalogable.catalog_items_included.first.catalogable.value
      else
        event.standard_credit_price
      end
    else
      catalog_item.catalogable.value
    end
  end

  def pack_with_unrefundable_credits?
    catalog_item = @order_item.catalog_item
    catalog_item.catalogable_type == "Pack" && !catalog_item.catalogable.credits_pack?
  end
end
