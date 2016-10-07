class Admins::Events::GtagAssignmentsController < Admins::Events::BaseController
  def new
    @profile = current_event.profiles.find(params[:id])
  end

  def create
    @profile = current_event.profiles.find(params[:id])
    gtag = current_event.gtags.find_by(tag_uid: permitted_params[:tag_uid].strip.upcase)

    if gtag
      if gtag.assigned_profile
        flash.now[:error] = I18n.t("alerts.gtag.already_assigned")
        render :new
      else
        @profile.credential_assignments.find_or_create_by!(credentiable: gtag, aasm_state: :assigned)
        redirect_to admins_event_profile_url(current_event, @profile), notice: I18n.t("alerts.created")
      end
    else
      flash.now[:error] = I18n.t("alerts.gtag.invalid")
      render :new
    end
  end

  def destroy
    @credential_assignment = CredentialAssignment.find(params[:id])
    @credential_assignment.unassign!
    @credential_assignment.credentiable

    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def permitted_params
    params.permit(:tag_uid).merge(event_id: current_event.id)
  end
end
