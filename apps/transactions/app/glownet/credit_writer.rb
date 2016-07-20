class CreditWriter
  def self.reassign_ticket(ticket, assignation)
    sign = 1 if assignation.eq?(:assign)
    sign = -1 if assignation.eq?(:unassign)
    ticket.credits.each do |credit|
      params = { credits: credit.total_amount * sign, credit_value: credit.value }
      create_credit(ticket.assigned_profile, params)
    end
  end

  # rubocop:disable Metrics/AbcSize
  def self.save_order(order, type = "online_topup")
    order.order_items.each do |item|
      params = { transaction_type: type }

      if item.single_credits?
        params[:credit_value] = item.catalog_item.catalogable.value
        params[:credits] = item.amount
        params[:refundable_credits] = item.amount

      elsif item.pack_with_credits?
        pack = item.catalog_item.catalogable
        pack.credits.each do |credit|
          params[:credit_value] = credit.value
          params[:credits] = credit.total_amount * item.amount
          params[:refundable_credits] = pack.only_credits_pack? ? item.total / credit.value : 0
        end
      end

      create_credit(order.profile, params) if params.key?(:credits)
    end
  end

  def self.create_credit(profile, atts)
    %w( credits refundable_credits credit_value ).each { |key| atts[key.to_sym] = atts[key.to_sym].to_f }

    common_atts = {
      transaction_category: "credit",
      transaction_type: "create_credit",
      transaction_origin: Transaction::ORIGINS[:portal],
      refundable_credits: atts[:credits],
      final_balance: profile.credits.to_f + atts[:credits].to_f,
      final_refundable_balance: profile.refundable_credits.to_f + atts[:refundable_credits].to_f,
      profile_id: profile.id,
      event_id: profile.event.id,
      device_created_at: Time.zone.now.strftime("%Y-%m-%d %T.%L")
    }.merge(atts)

    Operations::Base.new.portal_write(common_atts)
  end
end
