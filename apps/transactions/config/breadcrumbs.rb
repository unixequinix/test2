crumb :admins_event_transactions do |event, type|
  link t("breadcrumbs.#{type}_transactions"), admins_event_transactions_path(event, type: type)
  parent :admins_event, event
end

crumb :admins_event_transaction do |event, transaction, type|
  link transaction.id, admins_event_transaction_path(event, transaction, type)
  parent :admins_event_transactions, event, type
end

crumb :admins_event_missing_credit_inconsistencies do |event|
  link t("breadcrumbs.missing_transactions"), admins_event_missing_transactions_path(event)
  parent :admins_event, event
end

crumb :admins_event_real_credit_inconsistencies do |event|
  link t("breadcrumbs.credit_inconsistencies"), admins_event_credit_inconsistencies_path(event)
  parent :admins_event, event
end
