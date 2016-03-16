class CustomerCreditOrderCreator
  def save(order)
    order.order_items.each do |order_item|
      if order_item.single_credits?
        @customer_credit = CustomerCredit.new(
          customer_event_profile: order.customer_event_profile,
          transaction_origin: CustomerCredit::CREDITS_PURCHASE,
          payment_method: "none",
          credit_value: order_item.catalog_item.catalogable.value,
          amount: order_item.amount,
          refundable_amount: order_item.amount
        )
      elsif order_item.pack_with_credits?
        pack = order_item.catalog_item.catalogable
        if pack.only_credits_pack?
          pack.credits.each do |credit_item|
            @customer_credit = CustomerCredit.new(
              customer_event_profile: order.customer_event_profile,
              transaction_origin: CustomerCredit::CREDITS_PURCHASE,
              payment_method: "none",
              credit_value: credit_item.value,
              amount: credit_item.total_amount * order_item.amount,
              refundable_amount: order_item.total / credit_item.value * order_item.amount
            )
          end
        else
          pack.credits.each do |credit_item|
            @customer_credit = CustomerCredit.new(
              customer_event_profile: order.customer_event_profile,
              transaction_origin: CustomerCredit::CREDITS_PURCHASE,
              payment_method: "none",
              credit_value: credit_item.value,
              amount: credit_item.total_amount * order_item.amount,
              refundable_amount: 0
            )
          end
        end
      end
      calculate_balances if @customer_credit
      @customer_credit.save if @customer_credit && @customer_credit.valid?
    end
  end

  private

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
end
