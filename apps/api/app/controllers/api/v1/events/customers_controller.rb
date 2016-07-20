class Api::V1::Events::CustomersController < Api::V1::Events::BaseController
  def index
    modified = request.headers["If-Modified-Since"]
    profiles = @fetcher.sql_profiles(modified) || []

    if profiles.present?
      date = JSON.parse(profiles).map { |pr| pr["updated_at"] }.sort.last
      response.headers["Last-Modified"] = date.to_datetime.httpdate
    end

    render(json: profiles)
  end

  def show
    profile = @fetcher.profiles.find_by(id: params[:id])

    render status: :not_found, json: :not_found && return unless profile
    render json: profile, serializer: Api::V1::ProfileSerializer
  end
end
