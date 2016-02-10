module Api
  module V1
    module Events
      class GtagsController < Api::V1::Events::BaseController
        def index
          @gtags = Gtag.includes(:credential_assignments)
                   .where(event_id: current_event.id)

          render json: @gtags, each_serializer: Api::V1::GtagSerializer
        end

        def show
          @gtag = Gtag.includes(:credential_assignments)
                  .find_by(event_id: current_event.id, id: params[:id])

          render(status: :not_found, json: :not_found) && return if @gtag.nil?
          render json: @gtag, serializer: Api::V1::GtagSerializer
        end
      end
    end
  end
end
