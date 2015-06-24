class CreditsPresenter < BasePresenter
  def can_render?
    @event.ticketing?
  end

  def path
    'credits'
  end

  def customer_credit_sum
    customer.credit_logs.sum(:amount)
  end

  private

  def customer
    @customer ||= @admittance ? @admittance.admission.customer : Customer.new
  end
end
