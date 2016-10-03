class Api::V1::Events::PacksController < Api::V1::Events::BaseController
  def index
    render_entities("pack")
  end
end
