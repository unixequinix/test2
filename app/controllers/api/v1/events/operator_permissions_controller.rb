module Api
  module V1
    module Events
      class OperatorPermissionsController < Api::V1::EventsController
        before_action :set_modified

        def index
          permissions = @current_event.operator_permissions.includes(:station)
          permissions = permissions.where("catalog_items.updated_at > ?", @modified) if @modified
          date = permissions.maximum(:updated_at)&.httpdate
          permissions = permissions.map { |a| OperatorPermissionSerializer.new(a) }.to_json if permissions.present?

          render_entity(permissions, date)
        end
      end
    end
  end
end
