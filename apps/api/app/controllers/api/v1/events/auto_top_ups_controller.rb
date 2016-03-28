class Api::V1::Events::AutoTopUpsController < Api::V1::Events::BaseController
  skip_before_action :verify_authenticity_token

  def create
    render(status: :bad_request, json: { error: "Params missing." }) && return unless verify_params!
    render(status: :created, json: permitted_params)
  end

  private

  def verify_params!
    permitted_params.key?("gtag_uid") && permitted_params.key?("payment_method")
  end

  def permitted_params
    params.require(:auto_top_up).permit(:gtag_uid, :payment_method)
  end
end
