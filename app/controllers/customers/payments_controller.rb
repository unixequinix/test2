class Customers::PaymentsController < Customers::BaseController
  include ActiveMerchant::Billing::Integrations
  before_action :check_has_ticket!

  def create
  end

  def success
  end

  def error
  end

end