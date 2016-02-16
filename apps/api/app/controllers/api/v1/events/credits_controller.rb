class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  def index
    @credits = Credit.for_event(current_event)
    render json: @credits
  end
end
