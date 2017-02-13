class Api::V1::Events::DatabasesController < Api::V1::Events::BaseController
  def show
    type = params[:basic].eql?("true") ? "basic" : "full"
    database = DatabaseManager.new(@current_event, type)
    url = database.generate_url(5)

    render(status: :not_found, json: :not_found) && return unless url
    render(json: { url: url })
  end

  def create
    file = permitted_params[:file]
    render(status: :bad_request, json: { error: "File empty" }) && return unless file

    if permitted_params[:basic] == "true"
      @current_event.device_basic_db = file
    else
      @current_event.device_full_db = file
    end

    render(status: :created, json: :created) && return if @current_event.save
    render(status: :unprocessable_entity, json: { errors: @current_event.errors })
  end

  private

  def permitted_params
    params.permit(:file, :basic)
  end
end
