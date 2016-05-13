module CustomerAreaHelper
  def icon_to_draw(payment_service)
    payment_service = payment_service.to_sym
    if %i(paypal redsys braintree stripe paypal_nvp wirecard).include? payment_service
      fa_icon t("orders.payment-buttons.#{payment_service}.icon")
    elsif %i(ideal sofort).include? payment_service
      content_tag(:i, "", class: t("orders.payment-buttons.#{payment_service}.icon"))
    end
  end
end
