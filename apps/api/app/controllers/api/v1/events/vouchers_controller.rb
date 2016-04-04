class Api::V1::Events::VouchersController < Api::V1::Events::BaseController
  def index
    render_entities("voucher")
  end
end
