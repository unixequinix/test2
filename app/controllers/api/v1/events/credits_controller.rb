class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  def index
    render_200([Api::V1::CreditSerializer.new(@current_event.credit)])
  end
end
