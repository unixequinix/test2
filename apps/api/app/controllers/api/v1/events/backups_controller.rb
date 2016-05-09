class Api::V1::Events::BackupsController < Api::V1::Events::BaseController
  def create
    keys = [:device_uid, :backup_created_at, :backup].any? { |i| params[i] }
    render(status: :bad_request, json: { error: "params missing" }) && return unless keys
    render(status: :created, json: :created)
  end
end
