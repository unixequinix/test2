class Api::V1::Events::ParametersController < Api::V1::Events::BaseController
  def index
    render_entities("event_parameter")
  end
end
