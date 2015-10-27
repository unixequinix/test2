
require Rails.root.join('apps/core/lib/strategies/customer_password_strategy')
require Rails.root.join('apps/core/lib/strategies/admin_password_strategy')

Warden::Strategies.add(:customer_password, CustomerPasswordStrategy)
Warden::Strategies.add(:admin_password, AdminPasswordStrategy)