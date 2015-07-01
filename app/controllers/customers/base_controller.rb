class Customers::BaseController < ApplicationController
  before_action :authenticate_customer!
  before_action :fetch_current_event

  private

  def check_has_ticket!
    if current_customer.assigned_admission.nil?
      redirect_to customer_root_url
    end
  end

  def check_has_gtag!
    if current_customer.assigned_gtag_registration.nil?
      redirect_to customer_root_url
    end
  end
end
