class Customers::DashboardsController < Customers::BaseController
  def show
    @admittance = current_admission.assigned_admittance
    @gtag_registration = current_admission.assigned_gtag_registration
    @refund = current_customer.refund
    @presenter = DashboardPresenter.new(@admittance, @gtag_registration,
                                        @refund, current_event)
  end
end
