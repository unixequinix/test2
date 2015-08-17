class Admins::CustomersController < Admins::BaseController

  def index
    @q = Customer.with_deleted.search(params[:q])
    @customers = @q.result(distinct: true).page(params[:page]).includes(:assigned_admission, :assigned_gtag_registration)
  end

  def search
    index
    render :index
  end

  def show
    @customer = Customer.with_deleted.includes(:assigned_admission, :assigned_gtag_registration, admissions: :ticket, gtag_registrations: :gtag).find(params[:id])
  end

  def resend_confirmation
    @customer = Customer.find(params[:id])
    @customer.send_confirmation_instructions
  end
end
