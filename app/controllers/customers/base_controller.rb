class Customers::BaseController < ApplicationController
  before_action :authenticate_customer!

  private

  def check_has_ticket!
    if current_customer.assigned_admission.nil?
      redirect_to customer_root_url
    end
  end
end
