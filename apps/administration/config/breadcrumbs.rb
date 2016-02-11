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
  link "#{gtag.tag_serial_number} - #{gtag.tag_uid}", edit_admins_event_gtag_path(event, gtag)
  parent :admins_event_gtags, event
end

crumb :new_admins_event_gtag do |event|
  link t("breadcrumbs.new_gtag_type")
  parent :admins_event_gtags, event
end

## Credits

crumb :admins_event_credits do |event|
  link t("breadcrumbs.credits"), admins_event_credits_path(event)
  parent :admins_event, event
end

crumb :admins_event_credit do |event, credit|
  link credit.preevent_item.name, edit_admins_event_credit_path(event, credit)
  parent :admins_event_credits, event
end

crumb :new_admins_event_credit do |event|
  link t("breadcrumbs.new_credit_type")
  parent :admins_event_credits, event
end

## Vouchers

crumb :admins_event_vouchers do |event|
  link t("breadcrumbs.vouchers"), admins_event_vouchers_path(event)
  parent :admins_event, event
end

crumb :admins_event_voucher do |event, voucher|
  link voucher.preevent_item.name, edit_admins_event_voucher_path(event, voucher)
  parent :admins_event_vouchers, event
end

crumb :new_admins_event_voucher do |event|
  link t("breadcrumbs.new_voucher")
  parent :admins_event_vouchers, event
end

## CredentialTypes

crumb :admins_event_credential_types do |event|
  link t("breadcrumbs.credential_types"), admins_event_credential_types_path(event)
  parent :admins_event, event
end

crumb :admins_event_credential_type do |event, credential_type|
  link credential_type.preevent_item.name,
       edit_admins_event_credential_type_path(event, credential_type)
  parent :admins_event_credential_types, event
end

crumb :new_admins_event_credential_type do |event|
  link t("breadcrumbs.new_credential_type")
  parent :admins_event_credential_types, event
end

## PreeventProduct

crumb :admins_event_preevent_products do |event|
  link t("breadcrumbs.preevent_products"), admins_event_preevent_products_path(event)
  parent :admins_event, event
end

crumb :admins_event_preevent_product do |event, preevent_product|
  link preevent_product.name, edit_admins_event_preevent_product_path(event, preevent_product)
  parent :admins_event_preevent_products, event
end

crumb :new_admins_event_preevent_product do |event|
  link t("breadcrumbs.new_preevent_product")
  parent :admins_event_preevent_products, event
end

## Company

crumb :admins_event_companies do |event|
  link t("breadcrumbs.companies"), admins_event_companies_path(event)
  parent :admins_event, event
end

crumb :admins_event_company do |event, company|
  link company.name, edit_admins_event_company_path(event, company)
  parent :admins_event_companies, event
end

crumb :new_admins_event_company do |event|
  link t("breadcrumbs.new_company")
  parent :admins_event_companies, event
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
  link customer.name + " " + customer.surname, admins_event_customer_path(event, customer)
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

crumb :new_admins_event_customer_gtag_registration do |event, customer|
  link t("breadcrumbs.new_customer_gtag_registration")
  parent :admins_event_customers, event, customer
end

## Customer event profiles

crumb :admins_event_customer_event_profiles do |event|
  link t("breadcrumbs.customer_event_profile"), admins_event_customer_event_profiles_path(event)
  parent :admins_event, event
end

crumb :admins_event_customer_event_profile do |event, customer_event_profile|
  link customer_event_profile.customer.name + " " + customer_event_profile.customer.surname,
       admins_event_customer_path(event, customer_event_profile)
  parent :admins_event_customer_event_profiles, event
end

crumb :new_admins_event_customer_event_profile do |event|
  link t("breadcrumbs.new_customer_event_profile")
  parent :admins_event_customer_event_profiles, event
end

crumb :new_admins_event_customer_event_profile_admission do |event, customer_event_profile|
  link t("breadcrumbs.new_customer_event_profile_admission")
  parent :admins_event_customer_event_profiles, event, customer_event_profile
end

crumb :new_admins_event_customer_event_profile_gtag_registration do |event, customer_event_profile|
  link t("breadcrumbs.new_customer_event_profile_gtag_registration")
  parent :admins_event_customer_event_profiles, event, customer_event_profile
end

## Transactions

crumb :admins_event_transactions do |event|
  link "Transactions", admins_event_transactions_path(event)
  parent :admins_event, event
end
