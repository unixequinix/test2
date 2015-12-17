class Admins::Events::GtagAssignmentsController < Admins::Events::CredentialAssignmentsController

  def new
  end

  def create

  end
end

=begin
  def new
    @gtag_registration = GtagRegistration.new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
  end

  def create
    gtag = @fetcher.gtags.find_by(tag_uid: params[:tag_uid].strip.upcase, tag_serial_number: params[:tag_serial_number].strip.upcase)
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
    if !gtag.nil?
      @gtag_registration = current_customer_event_profile.gtag_registrations.build(gtag: gtag)
      if @gtag_registration.save
        flash[:notice] = I18n.t('alerts.created')
        GtagMailer.assigned_email(@gtag_registration).deliver_later
        redirect_to admins_event_customer_url(current_event, @customer)
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
    redirect_to admins_event_customer_url(current_event, @customer_event_profile.customer)
  end

  private

  def current_customer_event_profile
    current_customer.customer_event_profile ||
      CustomerEventProfile.new(customer: current_customer, event: current_event)
  end

  def current_customer
    Customer.find(params[:customer_id])
  end
=end