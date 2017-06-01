class Api::V1::Events::OperatorPermissionsController < Api::V1::Events::BaseController
  before_action :set_modified

  def index
    permissions = @current_event.operator_permissions.includes(:station)
    permissions = permissions.where("catalog_items.updated_at > ?", @modified) if @modified
    date = permissions.maximum(:updated_at)&.httpdate
    permissions = permissions.map { |a| Api::V1::OperatorPermissionSerializer.new(a) }.to_json if permissions.present?

    render_entity(permissions, date)
  end
end
