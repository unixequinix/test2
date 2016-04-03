crumb :admins_event_access_transactions do |event|
  link t("breadcrumbs.access_transactions"), admins_event_access_transactions_path(event)
  parent :admins_event, event
end
crumb :admins_event_credential_transactions do |event|
  link t("breadcrumbs.credential_transactions"), admins_event_credential_transactions_path(event)
  parent :admins_event, event
end
