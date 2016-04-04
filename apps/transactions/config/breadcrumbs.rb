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
