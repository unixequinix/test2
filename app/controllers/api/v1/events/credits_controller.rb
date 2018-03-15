module Api
  module V1
    module Events
      class CreditsController < Api::V1::EventsController
        def index
          credits = @current_event.catalog_items.where(type: %w[Credit VirtualCredit])
          credits = credits.map { |credit| CreditSerializer.new(credit) }
          render status: 200, json: credits.as_json
        end
      end
    end
  end
end
