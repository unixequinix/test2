class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  def index
    render status: 200, json: [Api::V1::CreditSerializer.new(@current_event.credit)].as_json
  end
end
