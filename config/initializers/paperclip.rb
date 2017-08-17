Paperclip.interpolates :slug do |attachment, style|
  attachment.instance.slug
end

Paperclip.interpolates :event_id do |attachment, style|
  attachment.instance.event_id
end

Paperclip.interpolates :category do |attachment, style|
  attachment.instance.category
end

Paperclip.interpolates :app_version do |attachment, style|
  attachment.instance.app_version.parameterize
end

Paperclip.interpolates :default_event_image_url do |attachment, style|
  ActionController::Base.helpers.asset_path('glownet-event-logo.png')
end

Paperclip.interpolates :default_event_background_url do |attachment, style|
  ActionController::Base.helpers.asset_path('background-default.jpg')
end

Paperclip.options[:content_type_mappings] = {
  db: "application/octet-stream"
}
