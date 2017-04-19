class Events::VouchupController < Events::PaymentsController
  before_action :set_order_details, only: %i[purchase refund]

  def purchase
    atts = {
      order_id: @order.id,
      auth_token: "TEST",
      success_url: event_vouchup_success_url(@current_event),
      error_url: event_vouchup_error_url(@current_event)
    }.to_param

    redirect_to "https://vouch-up.com/pay?#{atts}"
  end
end
