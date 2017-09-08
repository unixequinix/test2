class GtagCreator < ApplicationJob
  def perform(atts)
    return if atts[:tag_uid].blank?

    begin
      gtag = atts[:event].gtags.find_or_create_by(atts.slice(:tag_uid, :ticket_type_id))
    rescue ActiveRecord::RecordNotUnique
      retry
    end

    return if atts[:credits].blank? || atts[:credits].zero?

    customer = atts[:event].customers.create!

    gtag.update!(customer: customer, active: true)
    order = customer.build_order([[atts[:event].credit.id, atts[:credits]]])
    order.complete!
  end
end
