class Events::GtagAssignmentsController < Events::BaseController
  before_action :check_event_status!
  before_action :check_has_not_gtag_assignment!, only: [:new, :create]

  def new
    @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
  end

  def create
    gtag = current_event.gtags.find_by(tag_uid: permitted_params[:tag_uid].strip.upcase)

    if gtag
      if Profile::Checker.for_credentiable(gtag, current_customer)
        flash[:notice] = I18n.t("alerts.created")
        redirect_to event_url(current_event)
      else
        flash.now[:error] = I18n.t("alerts.gtag.already_assigned")
        @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
        render :new
      end
    else
      @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
      flash.now[:error] = I18n.t("alerts.gtag.invalid")
      render :new
    end
  end

  def destroy
    @gtag_assignment = CredentialAssignment.find(params[:id])
    @gtag_assignment.unassign!
    flash[:notice] = I18n.t("alerts.unassigned")
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

  def permitted_params
    params.require(:gtag_assignment_form).permit(:tag_uid).merge(event_id: current_event.id)
  end
end
