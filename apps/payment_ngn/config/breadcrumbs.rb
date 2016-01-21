## Payment Settings

crumb :admins_event_payment_settings do |event|
  link t("breadcrumbs.payment_settings"), admin_root_path
  parent :admins_event, event
end

## Orders

crumb :admins_event_orders do |event|
  link t("breadcrumbs.order"), admins_event_orders_path(event)
  parent :admins_event, event
end

crumb :admins_event_order do |event, order|
  link order.number, admins_event_order_path(event, order)
  parent :admins_event_orders, event
end

crumb :new_admins_event_order do |event|
  link t("breadcrumbs.new_order_type")
  parent :admins_event_orders, event
end

## Payments

crumb :admins_event_payments do |event|
  link t("breadcrumbs.payment"), admins_event_payments_path(event)
  parent :admins_event, event
end

crumb :admins_event_payment do |event, payment|
  link payment.id, admins_event_payment_path(event, payment)
  parent :admins_event_payments, event
end

crumb :new_admins_event_payment do |event|
  link t("breadcrumbs.new_payment_type")
  parent :admins_event_payments, event
end
