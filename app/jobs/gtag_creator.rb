class GtagCreator < ActiveJob::Base
  def perform(atts)
    gtag = Gtag.find_or_initialize_by(event_id: atts[:event_id], tag_uid: atts[:tag_uid])
    gtag.update(atts)
    return unless atts[:balance]
    gtag.update(balance)
    atts = { customer_tag_uid: gtag.tag_uid,
             gtag_counter: 0,
             gtag_id: gtag.id,
             final_balance: atts[:balance],
             final_refundable_balance: atts[:balance],
             refundable_credits: atts[:balance]
    }
    CreditTransaction.write!(event, "record_credit", :device, nil, nil, atts)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
