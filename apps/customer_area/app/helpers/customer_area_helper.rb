module CustomerAreaHelper
  def icon_to_draw(payment_service)
    binding.pry
    if %i(paypal redsys braintree stripe paypal_nvp).include? payment_service
      fa_icon t("orders.payment-buttons.#{payment_service}.icon")
    elsif %i(ideal sofort wirecard).include? payment_service
      content_tag(:div, class: "pf #{t('orders.payment-buttons.payment_service.icon')}")
    end
  end
end
