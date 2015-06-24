class Customers::BaseController < ApplicationController
  before_action :authenticate_customer!
  before_action :fetch_current_event

  def current_admission
    current_customer.admissions.for_event(current_event).first || Admission.new
  end

  private

  def check_has_ticket!
    redirect_to customer_root_url unless current_admission.assigned_admittance
  end
end
