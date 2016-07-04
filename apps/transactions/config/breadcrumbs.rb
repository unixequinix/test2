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
