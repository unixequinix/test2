crumb :root do
  link "Home TODO", admin_root_path
end

## -------------------------------------------------
## Admin
## -------------------------------------------------

## Dashboards

crumb :admins_root do
  link t("breadcrumbs.dashboard"), admin_root_path
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
