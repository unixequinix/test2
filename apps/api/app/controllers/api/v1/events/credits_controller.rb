class Api::V1::Events::CreditsController < Api::V1::Events::BaseController
  def index
    render_entities("credit")
  end
end
