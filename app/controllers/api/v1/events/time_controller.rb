class Api::V1::Events::TimeController < Api::V1::Events::BaseController
  def index
    render text: Time.zone.now
  end
end
