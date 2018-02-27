module Api
  module V1
    module Events
      class CreditsController < Api::V1::Events::BaseController
        def index
          credits = [@current_event.credit, @current_event.virtual_credit].compact.map { |credit| CreditSerializer.new(credit) }
          render status: 200, json: credits.as_json
        end
      end
    end
  end
end
