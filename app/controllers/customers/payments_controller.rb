class Customers::PaymentsController < Customers::BaseController
  before_action :check_has_ticket!

  def success
  end

  def error
  end
end