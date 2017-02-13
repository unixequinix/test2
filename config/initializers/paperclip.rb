Paperclip.interpolates :slug do |attachment, style|
  attachment.instance.slug
end

Paperclip.interpolates :default_event_image_url do |attachment, style|
  ActionController::Base.helpers.asset_path('glownet-event-logo.png')
end

Paperclip.options[:content_type_mappings] = {
  db: "application/octet-stream"
}
