module Api
  module V1
    module Events
      class PacksController < Api::V1::EventsController
        before_action :set_modified

        def index
          packs = @current_event.packs.includes(pack_catalog_items: :catalog_item)
          packs = packs.where("catalog_items.updated_at > ?", @modified) if @modified
          date = packs.maximum(:updated_at)&.httpdate
          packs = packs.map { |a| PackSerializer.new(a) }.as_json if packs.present?

          render_entity(packs, date)
        end
      end
    end
  end
end
