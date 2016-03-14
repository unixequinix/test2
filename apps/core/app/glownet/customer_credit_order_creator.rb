class CustomerCreditOrderCreator
  attr_reader :customer_credit

  def save(order)
    order.order_items.each do |order_item|
      @order_item =  order_item
      @event = order.customer_event_profile.event
      if order_item.single_credits?
        @customer_credit = CustomerCredit.new(
          customer_event_profile: order.customer_event_profile,
          transaction_origin: CustomerCredit::CREDITS_PURCHASE,
          payment_method: "none",
          credit_value: get_credit_value,
          amount: @order_item.amount,
          refundable_amount: calculate_refundable_amount
        )
        calculate_balances
        @customer_credit.save if @customer_credit.valid?
      end

      if order_item.valid_pack?
        pack = order_item.catalog_item.catalogable
        if pack.credits_pack?
          pack.credits.each do |credit_item|
              @customer_credit = CustomerCredit.new(
              customer_event_profile: order.customer_event_profile,
              transaction_origin: CustomerCredit::CREDITS_PURCHASE,
              payment_method: "none",
              credit_value: credit_item.value,
              amount: credit_item.total_amount * @order_item.amount,
              refundable_amount: calculate_refundable_amount
            )
            calculate_balances
            @customer_credit.save if @customer_credit.valid?
          end
        else
          pack.credits.each do |credit_item|
            @customer_credit = CustomerCredit.new(
              customer_event_profile: order.customer_event_profile,
              transaction_origin: CustomerCredit::CREDITS_PURCHASE,
              payment_method: "none",
              credit_value: credit_item.value,
              amount: credit_item.total_amount * @order_item.amount,
              refundable_amount: 0
            )
            calculate_balances
            @customer_credit.save if @customer_credit.valid?
          end
        end
      end
    end
  end

  def calculate_refundable_amount
    pack_with_unrefundable_credits? ? 0 : @order_item.total / get_credit_value
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

  def get_credit_value
    @order_item.catalog_item.catalogable.credits.first.value
  end

  def pack_with_unrefundable_credits?
    catalog_item = @order_item.catalog_item
    catalog_item.catalogable_type == "Pack" && !catalog_item.catalogable.credits_pack?
  end
end
