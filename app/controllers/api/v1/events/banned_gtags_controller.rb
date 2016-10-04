class Api::V1::Events::BannedGtagsController < Api::V1::Events::BaseController
  def index
    render_entities("banned_gtag")
  end
end
