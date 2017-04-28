class Events::VouchupController < Events::PaymentsController
  before_action :set_order_details, only: %i[purchase refund]

  def purchase
    redirect_to "https://vouch-up.com/pay/#{@current_event.slug}/#{@order.id}"
  end
end
