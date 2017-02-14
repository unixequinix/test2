class Events::GtagAssignmentsController < Events::EventsController
  before_action :check_has_not_gtag!, only: [:new, :create]

  def new
    @gtag = @current_event.gtags.new
  end

  def create
    @gtag = @current_event.gtags.find_by(tag_uid: permitted_params[:tag_uid].strip)

    flash.now[:error] = t("alerts.gtag.invalid") if @gtag.nil?
    flash.now[:error] = t("alerts.gtag.already_assigned") if @gtag&.customer
    render(:new) && return if flash.now[:error].present?

    @gtag.assign_customer(current_customer, :portal, current_customer)
    redirect_to event_path(@current_event), notice: t("alerts.created")
  end

  def destroy
    @gtag = @current_event.gtags.find(params[:id])
    @gtag.unassign_customer(:portal, current_customer)
    flash[:notice] = t("alerts.unassigned")
    redirect_to event_path(@current_event)
  end

  private

  def check_has_not_gtag!
    return if current_customer.active_gtag.nil?
    redirect_to event_path(@current_event), flash: { error: t("alerts.credential.already_assigned", item: "Tag") }
  end

  def permitted_params
    params.require(:gtag_assignment_form).permit(:tag_uid).merge(event_id: @current_event.id)
  end
end
