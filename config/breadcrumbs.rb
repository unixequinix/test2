crumb :root do
  link "Home TODO", admin_root_path
end

## -------------------------------------------------
## Admin
## -------------------------------------------------

crumb :admin_entitlements do
  link t("breadcrumbs.entitlements"), admin_entitlements_path
end

crumb :admin_entitlement do |entitlement|
  link entitlement.name, edit_admin_entitlement_path(entitlement)
  parent :admin_entitlements
end

crumb :new_admin_entitlement do
  link t("breadcrumbs.new_entitlement")
  parent :admin_entitlements
end
