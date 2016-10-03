class Api::V1::Events::ProductsController < Api::V1::Events::BaseController
  def index
    render_entities("product")
  end
end
