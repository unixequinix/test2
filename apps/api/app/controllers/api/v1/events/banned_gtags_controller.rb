module Api
  module V1
    module Events
      class BannedGtagsController < Api::V1::Events::BaseController
        def index
          @banned_gtags = Gtag.banned.where(event_id: current_event.id)
          render json: @banned_gtags, each_serializer: Api::V1::BannedGtagSerializer
        end
      end
    end
  end
end
