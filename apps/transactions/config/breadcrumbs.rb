crumb :admins_event_access_transactions do |event|
  link t("breadcrumbs.access_transactions"), admins_event_access_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_access_transaction do |event, transaction|
  link transaction.id, admins_event_access_transactions_path(event)
  parent :admins_event_access_transactions, event
end

crumb :admins_event_credential_transactions do |event|
  link t("breadcrumbs.credential_transactions"), admins_event_credential_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_credential_transaction do |event, transaction|
  link transaction.id, admins_event_credential_transactions_path(event)
  parent :admins_event_credential_transactions, event
end

crumb :admins_event_credit_transactions do |event|
  link t("breadcrumbs.credit_transactions"), admins_event_credit_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_credit_transaction do |event, transaction|
  link transaction.id, admins_event_credit_transactions_path(event)
  parent :admins_event_credit_transactions, event
end

crumb :admins_event_money_transactions do |event|
  link t("breadcrumbs.money_transactions"), admins_event_money_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_money_transaction do |event, transaction|
  link transaction.id, admins_event_money_transactions_path(event)
  parent :admins_event_money_transactions, event
end

crumb :admins_event_order_transactions do |event|
  link t("breadcrumbs.order_transactions"), admins_event_order_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_order_transaction do |event, transaction|
  link transaction.id, admins_event_order_transactions_path(event)
  parent :admins_event_order_transactions, event
end

crumb :admins_event_missing_transactions do |event|
  link t("breadcrumbs.missing_transactions"), admins_event_missing_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_credit_inconsistencies do |event|
  link t("breadcrumbs.credit_inconsistencies"), admins_event_credit_inconsistencies_path(event)
  parent :admins_event, event
end
