crumb :root do
  link t("admins.defaults.home"), admin_root_path
end

# transactions
crumb :admins_event_transactions do |event, type|
  link t("breadcrumbs.#{type}_transactions"), admins_event_transactions_path(event, type: type)
  parent :admins_event, event
end

crumb :admins_event_transaction do |event, transaction, type|
  link transaction.id, admins_event_transaction_path(event, transaction, type)
  parent :admins_event_transactions, event, type
end

crumb :admins_event_missing_credit_inconsistencies do |event|
  link t("breadcrumbs.missing_credit_inconsistencies"), missing_admins_event_credit_inconsistencies_path(event)
  parent :admins_event, event
end

crumb :admins_event_real_credit_inconsistencies do |event|
  link t("breadcrumbs.real_credit_inconsistencies"), real_admins_event_credit_inconsistencies_path(event)
  parent :admins_event, event
end

## Refund Settings

crumb :admins_event_refund_settings do |event|
  link t("breadcrumbs.refund_settings"), admin_root_path
  parent :admins_event, event
end

## Claims

crumb :admins_event_claims do |event|
  link t("breadcrumbs.claim"), admins_event_claims_path(event)
  parent :admins_event, event
end

crumb :admins_event_claim do |event, claim|
  link claim.number, admins_event_claim_path(event, claim)
  parent :admins_event_claims, event
end

crumb :new_admins_event_claim do |event|
  link t("breadcrumbs.new_claim_type")
  parent :admins_event_claims, event
end

## Refunds

crumb :admins_event_refunds do |event|
  link t("breadcrumbs.refund"), admins_event_refunds_path(event)
  parent :admins_event, event
end

crumb :admins_event_refund do |event, refund|
  link refund.id, admins_event_refund_path(event, refund)
  parent :admins_event_refunds, event
end

crumb :new_admins_event_refund do |event|
  link t("breadcrumbs.new_refund_type")
  parent :admins_event_refunds, event
end

## Payment Settings

crumb :admins_event_payment_settings do |event|
  link t("breadcrumbs.payment_settings"), admin_root_path
  parent :admins_event, event
end

## CustomerOrders

crumb :admins_event_customer_orders do |event|
  link t("breadcrumbs.customer_order"), admins_event_customer_orders_path(event)
  parent :admins_event, event
end

crumb :admins_event_customer_order do |event, customer_order|
  link customer_order.number, admins_event_customer_order_path(event, customer_order)
  parent :admins_event_customer_orders, event
end

crumb :new_admins_event_customer_order do |event|
  link t("breadcrumbs.new_customer_order_type")
  parent :admins_event_customer_orders, event
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

## -------------------------------------------------
## Admin
## -------------------------------------------------

## Devices

crumb :admin_devices do
  link t("breadcrumbs.devices"), admin_root_path
end

crumb :admins_device do |device|
  link device.asset_tracker, admin_device_path(device)
  parent :admin_devices
end

## Admins

crumb :admin_admins do
  link t("breadcrumbs.admins"), admin_admins_path
end

crumb :admins_admin do |admin|
  link admin.email, edit_admin_admin_path(admin)
  parent :admin_admins
end

crumb :new_admins_admin do
  link t("breadcrumbs.new_admin")
  parent :admin_admins
end

## Companies

crumb :admin_companies do
  link t("breadcrumbs.companies"), admin_companies_path
end

crumb :admin_company do |company|
  link company.name, admin_company_path(company)
  parent :admin_companies
end
crumb :edit_admin_company do |company|
  link company.name, edit_admin_company_path(company)
  parent :admin_companies
end

crumb :new_admin_company do
  link t("breadcrumbs.new_company")
  parent :admin_companies
end

## Company Event Agreements

crumb :admin_company_company_event_agreement do |company|
  link company.name, admin_company_company_event_agreements_path(company)
  parent :admin_companies
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

crumb :edit_admins_event_credit do |event, credit|
  link t("breadcrumbs.general.edit"), edit_admins_event_credit_path(event, credit)
  parent :admins_event_credit, event, credit
end

crumb :admins_event_credit do |event, credit|
  link credit.catalog_item.name, edit_admins_event_credit_path(event, credit)
  parent :admins_event_credits, event
end

crumb :new_admins_event_credit do |event|
  link t("breadcrumbs.general.new")
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

crumb :edit_admins_event_access do |event, pack|
  link t("breadcrumbs.general.edit"), edit_admins_event_pack_path(event, pack)
  parent :admins_event_pack, event, pack
end

crumb :admins_event_pack do |event, pack|
  link pack.catalog_item.name, edit_admins_event_pack_path(event, pack)
  parent :admins_event_packs, event
end

crumb :new_admins_event_pack do |event|
  link t("breadcrumbs.general.new")
  parent :admins_event_packs, event
end

## Products

crumb :admins_event_products do |event|
  link t("breadcrumbs.products"), admins_event_products_path(event)
  parent :admins_event, event
end

crumb :edit_admins_event_product do |event, product|
  link t("breadcrumbs.general.edit"), edit_admins_event_product_path(event, product)
  parent :admins_event_product, event, product
end

crumb :admins_event_product do |event, product|
  link product.name, edit_admins_event_product_path(event, product)
  parent :admins_event_products, event
end

crumb :new_admins_event_product do |event|
  link t("breadcrumbs.general.new")
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

## Profiles

crumb :admins_event_profiles do |event|
  link t("breadcrumbs.profile"), admins_event_profiles_path(event)
  parent :admins_event, event
end

crumb :admins_event_profile do |event, profile|
  link (profile.email || profile.id), admins_event_profile_path(event, profile)
  parent :admins_event_profiles, event
end

crumb :new_admins_event_profile do |event|
  link t("breadcrumbs.new_profile")
  parent :admins_event_profiles, event
end

crumb :admins_event_profile_gtag_assignation do |event, profile|
  link "Gtag assignation"
  parent :admins_event_profile, event, profile
end
