module CustomerAreaHelper
  def icon_to_draw(payment_service)
    if %i(paypal redsys braintree stripe paypal_nvp).include? payment_service
      fa_icon t("orders.payment-buttons.#{payment_service}.icon")
    elsif %i(ideal sofort wirecard).include? payment_service
      klass = t("orders.payment-buttons.#{payment_service}.icon")
      content_tag(:i, "", class: "pf #{klass}")
    end
  end
end
