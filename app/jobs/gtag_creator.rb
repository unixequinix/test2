class GtagCreator < ActiveJob::Base
  def perform(atts)
    gtag = Gtag.find_or_initialize_by(event_id: atts[:event_id], tag_uid: atts[:tag_uid])
    gtag.update!(atts)
    credits = atts[:credits]

    return if credits.blank?
    gtag.update!(final_balance: credits, final_refundable_balance: credits, refundable_credits: credits)

    t_atts = { customer_tag_uid: gtag.tag_uid,
               gtag_counter: 0,
               gtag_id: gtag.id,
               final_balance: credits,
               final_refundable_balance: credits,
               refundable_credits: credits,
               credits: credits }

    CreditTransaction.write!(Event.find(atts[:event_id]), "topup", :device, nil, nil, t_atts)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end
