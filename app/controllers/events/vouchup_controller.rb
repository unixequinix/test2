class Events::VouchupController < Events::PaymentsController
  before_action :set_order_details, only: %i[purchase refund]

  def purchase
    url = Rails.env.production? ? "vouch-up.com/pay" : "dev.vouch-up.com/pay"
    redirect_to URI.new("https://#{url}/#{@current_event.slug}/#{@order.id}")
  end

  def refund; end
end
