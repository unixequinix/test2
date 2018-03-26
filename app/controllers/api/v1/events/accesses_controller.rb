module Api
  module V1
    module Events
      class AccessesController < Api::V1::EventsController
        before_action :set_modified

        def index
          accesses = @current_event.accesses
          accesses = accesses.where("catalog_items.updated_at > ?", @modified) if @modified
          date = accesses.maximum(:updated_at)&.httpdate
          accesses = accesses.map { |a| AccessSerializer.new(a) }.to_json if accesses.present?

          render_entity(accesses, date)
        end
      end
    end
  end
end
