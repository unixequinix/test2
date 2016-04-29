class Api::V1::Events::AutoTopUpsController < Api::V1::Events::BaseController
  def create # rubocop:disable Metrics/CyclomaticComplexity
    keys = [:order_id, :gtag_uid, :payment_method].any? { |i| params[i] }
    render(status: :bad_request, json: { error: "params missing" }) && return unless keys

    order = Order.find_by_number(params[:order_id])
    render(status: :bad_request, json: { error: "order_id duplicated" }) && return if order

    payer = "Autotopup::#{params[:payment_method].downcase.camelize}AutoPayer".constantize
    payer = payer.start(params[:gtag_uid], params[:order_id], current_event)
    errors = payer[:errors]
    render(status: :unprocessable_entity, json: errors) && return if errors

    render(status: :created, json: payer)
  end
end
