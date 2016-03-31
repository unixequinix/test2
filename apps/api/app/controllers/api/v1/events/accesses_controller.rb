class Api::V1::Events::AccessesController < Api::V1::Events::BaseController
  def index
    render_entities("access")
  end
end
