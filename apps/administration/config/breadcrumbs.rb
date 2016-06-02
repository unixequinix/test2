crumb :root do
  link t("admins.defaults.home"), admin_root_path
end

## -------------------------------------------------
## Admin
## -------------------------------------------------

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

## Companies

crumb :admins_companies do
  link t("breadcrumbs.companies"), admins_companies_path
end

crumb :admins_company do |company|
  link company.name, admins_company_path(company)
  parent :admins_companies
end
crumb :edit_admins_company do |company|
  link company.name, edit_admins_company_path(company)
  parent :admins_companies
end

crumb :new_admins_company do
  link t("breadcrumbs.new_company")
  parent :admins_companies
end

## Company Event Agreements

crumb :admins_company_company_event_agreement do |company|
  link company.name, admins_company_company_event_agreements_path(company)
  parent :admins_companies
end

## Dashboards

crumb :admins_root do
  link t("breadcrumbs.dashboard"), admin_root_path
end

## Events

crumb :admins_events do
  link t("breadcrumbs.events"), admin_root_path
end

crumb :admins_event do |event|
  link event.name, admins_event_path(event)
end

crumb :new_admins_event do |_event|
  link t("breadcrumbs.new_event")
end

## Gtag Settings

crumb :admins_event_gtag_settings do |event|
  link t("breadcrumbs.gtag_settings"), admin_root_path
  parent :admins_event, event
end
## Gtag Keys

crumb :admins_event_gtag_keys do |event|
  link t("breadcrumbs.gtag_keys"), admin_root_path
  parent :admins_event, event
end

## Device Settings

crumb :admins_event_device_settings do |event|
  link t("breadcrumbs.device_settings"), admin_root_path
  parent :admins_event, event
end

## Tickets

crumb :admins_event_tickets do |event|
  link t("breadcrumbs.tickets"), admins_event_tickets_path(event)
  parent :admins_event, event
end

crumb :admins_event_ticket do |event, ticket|
  link ticket.code, edit_admins_event_ticket_path(event, ticket)
  parent :admins_event_tickets, event
end

crumb :new_admins_event_ticket do |event|
  link t("breadcrumbs.new_ticket")
  parent :admins_event_tickets, event
end

## GTag

crumb :admins_event_gtags do |event|
  link t("breadcrumbs.gtag"), admins_event_gtags_path(event)
  parent :admins_event, event
end

crumb :admins_event_gtag do |event, gtag|
  link gtag.tag_uid, edit_admins_event_gtag_path(event, gtag)
  parent :admins_event_gtags, event
end

crumb :new_admins_event_gtag do |event|
  link t("breadcrumbs.new_gtag")
  parent :admins_event_gtags, event
end

## Stations

crumb :admins_event_stations do |event, group|
  link t("breadcrumbs.#{group}_stations"), admins_event_stations_path(event, group: group)
  parent :admins_event, event
end

crumb :admins_event_station do |event, station|
  link station.name, edit_admins_event_station_path(event, station)
  parent :admins_event_stations, event, station.group
end

crumb :new_admins_event_station do |event, group|
  link t("breadcrumbs.new_station")
  parent :admins_event_stations, event, group
end

crumb :edit_admins_event_station do |event, station|
  link t("breadcrumbs.edit_station"), edit_admins_event_station_path(event, station)
  parent :admins_event_stations, event, station.group
end

crumb :station_items do |event, station|
  path = admins_event_station_station_items_path(current_event, station)
  link t("breadcrumbs.station_items"), path
  parent :admins_event_station, event, station
end
## Accesses

crumb :admins_event_accesses do |event|
  link t("breadcrumbs.accesses"), admins_event_accesses_path(event)
  parent :admins_event, event
end

crumb :edit_admins_event_access do |event, access|
  link t("breadcrumbs.general.edit"), edit_admins_event_access_path(event, access)
  parent :admins_event_access, event, access
end

crumb :admins_event_access do |event, access|
  link access.catalog_item.name, edit_admins_event_access_path(event, access)
  parent :admins_event_accesses, event
end

crumb :new_admins_event_access do |event|
  link t("breadcrumbs.general.new")
  parent :admins_event_accesses, event
end

## Credits

crumb :admins_event_credits do |event|
  link t("breadcrumbs.credits"), admins_event_credits_path(event)
  parent :admins_event, event
end

crumb :admins_event_credit do |event, credit|
  link credit.catalog_item.name, edit_admins_event_credit_path(event, credit)
  parent :admins_event_credits, event
end

crumb :new_admins_event_credit do |event|
  link t("breadcrumbs.new_credit")
  parent :admins_event_credits, event
end

## Vouchers

crumb :admins_event_vouchers do |event|
  link t("breadcrumbs.vouchers"), admins_event_vouchers_path(event)
  parent :admins_event, event
end

crumb :admins_event_voucher do |event, voucher|
  link voucher.catalog_item.name, edit_admins_event_voucher_path(event, voucher)
  parent :admins_event_vouchers, event
end

crumb :new_admins_event_voucher do |event|
  link t("breadcrumbs.new_voucher")
  parent :admins_event_vouchers, event
end

## Packs

crumb :admins_event_packs do |event|
  link t("breadcrumbs.packs"), admins_event_packs_path(event)
  parent :admins_event, event
end

crumb :admins_event_pack do |event, pack|
  link pack.catalog_item.name, edit_admins_event_pack_path(event, pack)
  parent :admins_event_packs, event
end

crumb :new_admins_event_pack do |event|
  link t("breadcrumbs.new_pack")
  parent :admins_event_packs, event
end

## Products

crumb :admins_event_products do |event|
  link t("breadcrumbs.products"), admins_event_products_path(event)
  parent :admins_event, event
end

crumb :admins_event_product do |event, product|
  link product.name, edit_admins_event_product_path(event, product)
  parent :admins_event_products, event
end

crumb :new_admins_event_product do |event|
  link t("breadcrumbs.new_product")
  parent :admins_event_products, event
end

## CredentialTypes

crumb :admins_event_credential_types do |event|
  link t("breadcrumbs.credential_types"), admins_event_credential_types_path(event)
  parent :admins_event, event
end

crumb :admins_event_credential_type do |event, credential_type|
  link credential_type.catalog_item.name,
       edit_admins_event_credential_type_path(event, credential_type)
  parent :admins_event_credential_types, event
end

crumb :new_admins_event_credential_type do |event|
  link t("breadcrumbs.new_credential_type")
  parent :admins_event_credential_types, event
end

## CompanyTicketType

crumb :admins_event_company_ticket_types do |event|
  link t("breadcrumbs.company_ticket_types"), admins_event_company_ticket_types_path(event)
  parent :admins_event, event
end

crumb :admins_event_company_ticket_type do |event, company_ticket_type|
  link company_ticket_type.name,
       edit_admins_event_company_ticket_type_path(event, company_ticket_type)
  parent :admins_event_company_ticket_types, event
end

crumb :new_admins_event_company_ticket_type do |event|
  link t("breadcrumbs.new_company_ticket_type")
  parent :admins_event_company_ticket_types, event
end

## Customers

crumb :admins_event_customers do |event|
  link t("breadcrumbs.customers"), admins_event_customers_path(event)
  parent :admins_event, event
end

crumb :admins_event_customer do |event, customer|
  link customer.first_name + " " + customer.last_name, admins_event_customer_path(event, customer)
  parent :admins_event_customers, event
end

crumb :new_admins_event_customer do |event|
  link t("breadcrumbs.new_customer")
  parent :admins_event_customers, event
end

crumb :new_admins_event_customer_admission do |event, customer|
  link t("breadcrumbs.new_customer_admission")
  parent :admins_event_customers, event, customer
end

crumb :new_admins_event_customer_gtag_assignation do |event, customer|
  link t("breadcrumbs.new_customer_gtag_assignation")
  parent :admins_event_customers, event, customer
end

## Profiles

crumb :admins_event_profiles do |event|
  link t("breadcrumbs.profile"), admins_event_profiles_path(event)
  parent :admins_event, event
end

crumb :admins_event_profile do |event, profile|
  link profile.id,
       admins_event_customer_path(event, profile)
  parent :admins_event_profiles, event
end

crumb :new_admins_event_profile do |event|
  link t("breadcrumbs.new_profile")
  parent :admins_event_profiles, event
end
