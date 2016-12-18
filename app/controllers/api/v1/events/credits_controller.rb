class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  def index
    date = @current_event.credit.updated_at.httpdate
    credit = ActiveModelSerializers::Adapter.create([Api::V1::CreditSerializer.new(@current_event.credit)]).to_json
    render_entity(credit, date)
  end
end
