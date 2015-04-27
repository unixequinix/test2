class Customer::BaseController < ApplicationController
  before_action :authenticate_customer!

  private

  def check_has_ticket!
    if current_customer.assigned_admission.nil?
      redirect_to new_customer_admission_url
    end
  end
end
