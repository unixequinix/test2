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