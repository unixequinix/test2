class Admins::Events::GtagAssignmentsController < Admins::Events::CredentialAssignmentsController

  def new
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])
    @gtag_assignment_form = GtagAssignmentForm.new
  end

  def create
    @gtag_assignment_form = GtagAssignmentForm.new(gtag_assignment_parameters)
    gtag = @fetcher.gtags.find_by(
      tag_uid: @gtag_assignment_form.tag_uid.strip.upcase,
      tag_serial_number: @gtag_assignment_form.tag_serial_number.strip.upcase
    )
    @customer = @fetcher.customers.with_deleted.find(params[:customer_id])

    if !gtag.nil?
      @gtag_registration = current_customer_event_profile.credential_assignments_gtags.build(credentiable: gtag)
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
    @credential_assignment = CredentialAssignment.find(params[:id])
    customer_event_profile = @credential_assignment.customer_event_profile
    @credential_assignment.unassign!
    gtag = @credential_assignment.credentiable

    flash[:notice] = I18n.t('alerts.unassigned')
    GtagMailer.unassigned_email(@credential_assignment).deliver_later

    redirect_to admins_event_customer_url(current_event, customer_event_profile.customer)
  end

  private

  def gtag_assignment_parameters
    params.require(:gtag_assignment_form).permit(:number, :tag_uid, :tag_serial_number)
  end

end


=begin
  def new
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
=end

