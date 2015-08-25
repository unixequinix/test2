class Admins::Events::GtagRegistrationsController < Admins::Events::BaseController

  def new
    @gtag_registration = GtagRegistration.new
    @customer_event_profile = CustomerEventProfile.with_deleted.find(params[:customer_event_profile_id])
  end

  def create
    gtag = Gtag.find_by(tag_uid: params[:tag_uid].strip.upcase, tag_serial_number: params[:tag_serial_number].strip.upcase)
    @customer_event_profile = CustomerEventProfile.with_deleted.find(params[:customer_event_profile_id])
    if !gtag.nil?
      @gtag_registration = GtagRegistration.new(customer_event_profile_id: params[:customer_event_profile_id], gtag_id: gtag.id)
      if @gtag_registration.save
        flash[:notice] = I18n.t('alerts.created')
        GtagMailer.assigned_email(@gtag_registration).deliver_later
        redirect_to admins_event_customer_event_profile_url(current_event, @customer_event_profile)
      else
        flash[:error] = @gtag_registration.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t('alerts.gtag')
      render :new
    end
  end

  def destroy
    @gtag_registration = GtagRegistration.find(params[:id])
    @customer_event_profile = @gtag_registration.customer_event_profile
    @gtag_registration.unassign!
    flash[:notice] = I18n.t('alerts.unassigned')
    GtagMailer.unassigned_email(@gtag_registration).deliver_later
    redirect_to admins_event_customer_event_profile_url(current_event, @customer_event_profile)
  end
end
