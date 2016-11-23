class Api::V1::Events::UserFlagsController < Api::V1::Events::BaseController
  def index
    render_entities("user_flag")
  end
end
