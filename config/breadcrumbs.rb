crumb :root do
  link "Home TODO", admin_root_path
end

## -------------------------------------------------
## Admin
## -------------------------------------------------


## Entitlements

crumb :admin_entitlements do
  link t("breadcrumbs.entitlements"), admin_entitlements_path
end

crumb :admin_entitlement do |entitlement|
  link entitlement.name, edit_admin_entitlement_path(entitlement)
  parent :admin_entitlements
end

crumb :new_admin_entitlement do
  link t("breadcrumbs.new_entitlement")
  parent :admin_entitlements
end

## TicketsTypes

crumb :admin_ticket_types do
  link t("breadcrumbs.ticket_types"), admin_ticket_types_path
end

crumb :admin_ticket_type do |ticket_type|
  link ticket_type.name, edit_admin_ticket_type_path(ticket_type)
  parent :admin_ticket_types
end

crumb :new_admin_ticket_type do
  link t("breadcrumbs.new_ticket_type")
  parent :admin_ticket_types
end

## Tickets

crumb :admin_tickets do
  link t("breadcrumbs.tickets"), admin_tickets_path
end

crumb :admin_ticket do |ticket|
  link ticket.number, edit_admin_ticket_path(ticket)
  parent :admin_tickets
end

crumb :new_admin_ticket do
  link t("breadcrumbs.new_ticket")
  parent :admin_tickets
end

## OnlineProducts

crumb :admin_online_products do
  link t("breadcrumbs.online_products"), admin_online_products_path
end

crumb :admin_online_product do |ticket|
  link online_product.name, edit_admin_online_product_path(online_product)
  parent :admin_online_products
end

crumb :new_admin_online_product do
  link t("breadcrumbs.new_online_product")
  parent :admin_online_products
end