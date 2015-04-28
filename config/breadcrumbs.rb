crumb :root do
  link "Home TODO", admin_root_path
end

## -------------------------------------------------
## Admin
## -------------------------------------------------


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

crumb :admins_online_products do
  link t("breadcrumbs.online_products"), admins_online_products_path
end

crumb :admins_online_product do |online_product|
  link online_product.name, edit_admins_online_product_path(online_product)
  parent :admins_online_products
end

crumb :new_admins_online_product do
  link t("breadcrumbs.new_online_product")
  parent :admins_online_products
end