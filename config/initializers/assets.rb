# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '2.1'

# Add additional assets to the asset load path
# Rails.application.config.assets.paths << Emoji.images_path

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
# Rails.application.config.assets.precompile += %w( search.js )

assets = %w( .svg .eot .woff .ttf welcome_admin.css admin.css cable.js customer.css customer.js layout.css)
Rails.application.config.assets.precompile += assets

specific = %w( specific/pivot_tables.js specific/events-form.js specific/intercom.js specific/devices_draggable.js specific/ticket_types_draggable.js)
Rails.application.config.assets.precompile += specific
