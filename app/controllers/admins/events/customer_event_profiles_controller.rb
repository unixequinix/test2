class Admins::Events::CustomerEventProfilesController < Admins::Events::BaseController

  def index
    @q = CustomerEventProfile.where(event_id: current_event.id).with_deleted.search(params[:q])
    @customer_event_profiles = @q.result(distinct: true).page(params[:page]).includes(:customer, :assigned_admission, :assigned_gtag_registration)
  end

  def search
    index
    render :index
  end

  def show
    @customer_event_profile = CustomerEventProfile.where(event_id: current_event.id).with_deleted.includes(:customer, :assigned_admission, :assigned_gtag_registration, admissions: :ticket, gtag_registrations: [:gtag, gtag: :gtag_credit_log]).find(params[:id])
  end

  def resend_confirmation
    @customer = CustomerEventProfile.find(params[:id]).customer
    @customer.send_confirmation_instructions
  end
end
