class Operations::Credit::BalanceUpdater < Operations::Base
  TRIGGERS = %w( sale topup refund fee sale_refund online_topup auto_topup create_credit ticket_credit ).freeze

  def perform(atts)
    credit_atts = column_attributes(CustomerCredit, atts)

    # TODO: this is because of disparity of variables between portal and device, remove when fixed
    credit_atts.merge!(refundable_amount: atts[:credits_refundable],
                       amount: atts[:credits],
                       payment_method: "credits",
                       created_in_origin_at: atts[:device_created_at])
    CustomerCredit.create!(credit_atts)
  end
end
