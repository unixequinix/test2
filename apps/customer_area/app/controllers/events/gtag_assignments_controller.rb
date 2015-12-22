class Events::GtagAssignmentsController < Events::BaseController
  before_action :check_event_status!
  before_action :check_has_not_gtag_registration!, only: [:new, :create]

  def new
    @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
  end

  def create
    gtag = Gtag.find_by(tag_uid: params[:tag_uid].strip.upcase, tag_serial_number: params[:tag_serial_number].strip.upcase, event: current_event)
    if !gtag.nil?
      @gtag_assignment = current_customer_event_profile.credential_assignments.build(credentiable: gtag)
      if @gtag_assignment.save
        flash[:notice] = I18n.t("alerts.created")
        GtagMailer.assigned_email(@gtag_assignment).deliver_later
        redirect_to event_url(current_event)
      else
        flash[:error] = @gtag_assignment.errors.full_messages.join(". ")
        render :new
      end
    else
      flash[:error] = I18n.t("alerts.gtag")
      @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
      render :new
    end
  end

  def destroy
    @gtag_assignment = CredentialAssignment.find(params[:id])
    @gtag_assignment.unassign!
    flash[:notice] = I18n.t("alerts.unassigned")
    GtagMailer.unassigned_email(@gtag_assignment).deliver_later
    redirect_to event_url(current_event)
  end

  private

  def check_event_status!
    unless current_event.gtag_registration?
      flash.now[:error] = I18n.t("alerts.error")
      redirect_to event_url(current_event)
    end
  end

  def check_has_not_gtag_registration!
    unless current_customer_event_profile.credential_assignments_gtag_assigned.nil?
      redirect_to event_url(current_event), flash: { error: I18n.t("alerts.already_assigned") }
    end
  end
end