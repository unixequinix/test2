class Api::V1::Events::AutoTopUpsController < Api::V1::Events::BaseController
  skip_before_action :verify_authenticity_token

  def create
    uid = params[:auto_top_up][:gtag_uid]
    payment = params[:auto_top_up][:payment_method]
    render(status: :bad_request, json: { error: "params missing" }) && return unless uid && payment

    profile = Gtag.find_by_tag_uid(uid).assigned_customer_event_profile
    payer = "Autotopup::#{payment.capitalize}AutoPayer".constantize.pay(profile)

    render(status: :unprocessable_entity, json: :no_content) && return unless payer
    render(status: :created, json: :created)
  end
end
