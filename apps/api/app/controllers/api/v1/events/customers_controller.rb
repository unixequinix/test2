class Api::V1::Events::CustomersController < Api::V1::Events::BaseController
  def index # rubocop:disable Metrics/AbcSize
    render(json: @fetcher.sql_customer_event_profiles)
    # if request.headers["If-Modified-Since"]
    #   date = request.headers["If-Modified-Since"].to_time + 1
    #   customers = @fetcher.customer_event_profiles
    #               .where("customer_event_profiles.updated_at > ?", date)
    #
    #   response.headers["Last-Modified"] = customers.maximum(:updated_at).to_s
    #   render(json: customers, each_serializer: Api::V1::CustomerEventProfileSerializer)
    # else
    #
    #   last_updated = Rails.cache.fetch("v1/event/#{current_event.id}/customers_updated_at",
    #                                    expires_in: 12.hours) do
    #     @fetcher.customer_event_profiles.maximum(:updated_at).to_s
    #   end
    #
    #   response.headers["Last-Modified"] = last_updated
    #   render(json: Rails.cache.fetch("v1/event/#{current_event.id}/customers",
    #          expires_in: 12.hours) { @fetcher.sql_customer_event_profiles })
    # end
  end

  def show
    profile = @fetcher.customer_event_profiles.find_by(id: params[:id])

    render status: :not_found, json: :not_found && return unless profile
    render json: profile, serializer: Api::V1::CustomerEventProfileSerializer
  end
end
