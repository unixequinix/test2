class Api::V1::Events::AutoTopUpsController < Api::V1::Events::BaseController
  skip_before_action :verify_authenticity_token

  def create
    render(status: :bad_request, json: { error: "Params missing." }) && return unless verify_params!

    customer = Gtag.find_by_tag_uid(permitted_params[:gtag_uid])
               .credential_assignments
               .first
               .customer_event_profile

    method = "Autotopup::#{permitted_params[:payment_method].capitalize}AutoPayer".constantize
    payment = method.new(customer)
    payment.start

    binding.pry
    errors = payment.errors
    render(status: :unprocessable_entity, json: { errors: errors }) && return if errors
    render(status: :created, json: { customer_id: customer.id })
  end

  private

  def verify_params!
    permitted_params.key?("gtag_uid") && permitted_params.key?("payment_method")
  end

  def permitted_params
    params.require(:auto_top_up).permit(:gtag_uid, :payment_method)
  end
end
