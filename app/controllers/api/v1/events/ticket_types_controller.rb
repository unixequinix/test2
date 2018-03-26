module Api
  module V1
    module Events
      class TicketTypesController < Api::V1::EventsController
        before_action :set_modified

        def index
          types = @current_event.ticket_types.for_devices
          types = types.where("ticket_types.updated_at > ?", @modified) if @modified
          date = types.maximum(:updated_at)&.httpdate
          types = types.map { |a| TicketTypeSerializer.new(a) }.as_json if types.present?

          render_entity(types, date)
        end
      end
    end
  end
end
