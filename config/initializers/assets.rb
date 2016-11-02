# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.1'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Rails.root.join('apps', 'core', 'app', 'assets')

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

# Precompile additional assets
assets = %w( .svg .eot .woff .ttf welcome_admin.css admin.css admin.js admin_mobile.css admin_mobile.js customer.css customer.js)
Rails.application.config.assets.precompile += assets
