## Refund Settings

crumb :admins_event_refund_settings do |event|
  link t('breadcrumbs.refund_settings'), admin_root_path
  parent :admins_event, event
end

## Claims

crumb :admins_event_claims do |event|
  link t('breadcrumbs.claim'), admins_event_claims_path(event)
  parent :admins_event, event
end

crumb :admins_event_claim do |event, claim|
  link claim.number, admins_event_claim_path(event, claim)
  parent :admins_event_claims, event
end

crumb :new_admins_event_claim do |event|
  link t('breadcrumbs.new_claim_type')
  parent :admins_event_claims, event
end

## Refunds

crumb :admins_event_refunds do |event|
  link t('breadcrumbs.refund'), admins_event_refunds_path(event)
  parent :admins_event, event
end

crumb :admins_event_refund do |event, refund|
  link refund.id, admins_event_refund_path(event, refund)
  parent :admins_event_refunds, event
end

crumb :new_admins_event_refund do |event|
  link t('breadcrumbs.new_refund_type')
  parent :admins_event_refunds, event
end
