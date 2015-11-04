class Admins::Events::CustomersController < Admins::Events::BaseController
 def index
    @q = @fetcher.customers.with_deleted.search(params[:q])
    @customers = @q.result(distinct: true).page(params[:page]).includes(:customer_event_profile, customer_event_profile: [:assigned_admissions, :assigned_gtag_registration, assigned_admissions: :ticket, admissions: :ticket] )
  end

  def search
    index
    render :index
  end

  def show
    @customer = @fetcher.customers.with_deleted.includes(:customer_event_profile, customer_event_profile: [:assigned_admissions, :assigned_gtag_registration, admissions: :ticket, gtag_registrations: [:gtag, gtag: :gtag_credit_log]]).find(params[:id])
  end

  def resend_confirmation
    @customer = @fetcher.customers.find(params[:id])
    CustomerMailer.confirmation_instructions_email(@customer).deliver_later
  end
end