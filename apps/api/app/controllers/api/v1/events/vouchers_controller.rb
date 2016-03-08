class Api::V1::Events::VouchersController < Api::V1::Events::BaseController
  def index
    render json: @fetcher.vouchers, each_serializer: Api::V1::VoucherSerializer
  end
end
