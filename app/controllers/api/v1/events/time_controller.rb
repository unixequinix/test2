class Api::V1::Events::TimeController < Api::V1::Events::BaseController
  def index
    Time.zone = current_event.timezone.blank? ? "Madrid" : current_event.timezone
    render text: Time.zone.now.as_json
  end
end
