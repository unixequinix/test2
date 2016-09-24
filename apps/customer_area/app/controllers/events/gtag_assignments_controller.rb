class Events::GtagAssignmentsController < Events::BaseController
  before_action :check_event_status!
  before_action :check_has_not_gtag_assignment!, only: [:new, :create]
  # before_action :check_is_valid_status!, only: [:destroy]

  def new
    @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
  end

  def create
    @gtag_assignment_form = GtagAssignmentForm.new(gtag_assignment_parameters)
    if @gtag_assignment_form.save(current_event.gtags, current_customer)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to event_url(current_event)
    else
      flash.now[:error] = @gtag_assignment_form.errors.full_messages.join
      @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
      render :new
    end
  end

  def destroy
    @gtag_assignment = CredentialAssignment.find(params[:id])
    @gtag_assignment.unassign!
    flash[:notice] = I18n.t("alerts.unassigned")
    # TODO: Removed for Sonar with potential permanent removal
    # GtagMailer.unassigned_email(@gtag_assignment).deliver_later
    redirect_to event_url(current_event)
  end

  private

  def check_event_status!
    return if current_event.gtag_assignation?
    redirect_to event_url(current_event), flash: { error: I18n.t("alerts.error") }
  end

  def check_has_not_gtag_assignment!
    return if current_profile.active_gtag_assignment.nil?
    redirect_to event_url(current_event), flash: { error: I18n.t("alerts.gtag_already_assigned") }
  end

  def check_is_valid_status!
    return if !current_event.started? && !current_event.finished?
    redirect_to event_url(current_event), flash: { error: I18n.t("alerts.forbidden_gtag_change") }
  end

  def gtag_assignment_parameters
    params.require(:gtag_assignment_form)
          .permit(:number, :tag_uid).merge(event_id: current_event.id)
  end
end
