class CustomerCreditCreator
  attr_reader :customer_credit

  def initialize(attributes)
    @order_item =  attributes[:order_item]
    @customer_credit = CustomerCredit.new(
      customer_event_profile: attributes[:customer_event_profile],
      transaction_origin: attributes[:transaction_origin],
      payment_method: attributes[:payment_method],
      credit_value: get_credit_value(attributes[:customer_event_profile].event),
      amount: @order_item.credits_included,
      refundable_amount: calculate_refundable_amount(attributes[:customer_event_profile].event)
    )
  end

  def save
    calculate_balances
    @customer_credit.save if @customer_credit.valid?
  end

  def calculate_refundable_amount(event)
    catalog_item = @order_item.catalog_item
    if catalog_item.catalogable_type == "Pack"
      if catalog_item.catalogable.credits_pack?
        @order_item.total / get_credit_value(event)
      else
        return 0
      end
    else
      @order_item.total / get_credit_value(event)
    end
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
end
