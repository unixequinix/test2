class Api::V1::Events::AutoTopUpsController < Api::V1::Events::BaseController
  def create # rubocop:disable Metrics/CyclomaticComplexity
    uid = params[:gtag_uid]
    pay = params[:payment_method]
    o = params[:order_id]

    render(status: :bad_request, json: { error: "params missing" }) && return unless uid && pay && o

    payer = "Autotopup::#{pay.downcase.camelize}AutoPayer".constantize.start(uid, o)

    render(status: :unprocessable_entity, json: payer) && return if payer[:errors]
    render(status: :created, json: payer)
  end
end
