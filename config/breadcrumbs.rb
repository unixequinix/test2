crumb :root do
  link t("admins.defaults.home"), admin_root_path
end

## -------------------------------------------------
## Admin
## -------------------------------------------------

## Dashboards

crumb :admins_root do
  link t("breadcrumbs.dashboard"), admin_root_path
end

## Admins

crumb :admins_admins do
  link t("breadcrumbs.admins"), admins_admins_path
end

crumb :admins_admin do |admin|
  link admin.email, edit_admins_admin_path(admin)
  parent :admins_admins
end

crumb :new_admins_admin do
  link t("breadcrumbs.new_admin")
  parent :admins_admins
end

## Entitlements

crumb :admins_entitlements do
  link t("breadcrumbs.entitlements"), admins_entitlements_path
end

crumb :admins_entitlement do |entitlement|
  link entitlement.name, edit_admins_entitlement_path(entitlement)
  parent :admins_entitlements
end

crumb :new_admins_entitlement do
  link t("breadcrumbs.new_entitlement")
  parent :admins_entitlements
end

## TicketsTypes

crumb :admins_ticket_types do
  link t("breadcrumbs.ticket_types"), admins_ticket_types_path
end

crumb :admins_ticket_type do |ticket_type|
  link ticket_type.name, edit_admins_ticket_type_path(ticket_type)
  parent :admins_ticket_types
end

crumb :new_admins_ticket_type do
  link t("breadcrumbs.new_ticket_type")
  parent :admins_ticket_types
end

## Tickets

crumb :admins_tickets do
  link t("breadcrumbs.tickets"), admins_tickets_path
end

crumb :admins_ticket do |ticket|
  link ticket.number, edit_admins_ticket_path(ticket)
  parent :admins_tickets
end

crumb :new_admins_ticket do
  link t("breadcrumbs.new_ticket")
  parent :admins_tickets
end

## GTag

crumb :admins_gtags do
  link t("breadcrumbs.gtags"), admins_gtags_path
end

crumb :admins_gtag do |gtag|
  link "#{gtag.tag_uid}-#{gtag.tag_serial_number}", edit_admins_gtag_path(gtag)
  parent :admins_gtags
end

crumb :new_admins_gtag do
  link t("breadcrumbs.new_gtag")
  parent :admins_gtags
end

## OnlineProducts

crumb :admins_credits do
  link t("breadcrumbs.credits"), admins_credits_path
end

crumb :admins_credit do |credit|
  link credit.online_product.name, edit_admins_credit_path(credit)
  parent :admins_credits
end

crumb :new_admins_credit do
  link t("breadcrumbs.new_credit")
  parent :admins_credits
end

## Customers

crumb :admins_customers do
  link t("breadcrumbs.customers"), admins_customers_path
end

crumb :admins_customer do |customer|
  link customer.name, admins_customer_path(customer)
  parent :admins_customers
end

crumb :new_admins_customer do
  link t("breadcrumbs.new_customer")
  parent :admins_customers
end


## Orders

crumb :admins_orders do
  link t("breadcrumbs.orders"), admins_orders_path
end

crumb :admins_order do |order|
  link order.number, admins_order_path(order)
  parent :admins_orders
end

crumb :new_admins_order do
  link t("breadcrumbs.new_order")
  parent :admins_orders
end


## Payments

crumb :admins_payments do
  link t("breadcrumbs.payments"), admins_payments_path
end

crumb :admins_payment do |payment|
  link payment.id, admins_payment_path(payment)
  parent :admins_payments
end

crumb :new_admins_payment do
  link t("breadcrumbs.new_payment")
  parent :admins_payments
end

## Payments

crumb :admins_refunds do
  link t("breadcrumbs.refunds"), admins_refunds_path
end

crumb :admins_refund do |refund|
  link refund.id, admins_refund_path(refund)
  parent :admins_refunds
end

crumb :new_admins_refund do
  link t("breadcrumbs.new_refund")
  parent :admins_refunds
end
