class Events::GtagAssignmentsController < Events::EventsController
  before_action :check_has_not_gtag!, only: %i[new create]

  def create # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize, Metrics/PerceivedComplexity
    @code = permitted_params[:tag_uid].strip
    @gtag = @current_event.gtags.find_by(tag_uid: @code)
    recycle_present = @current_event.transactions.where(action: "gtag_recycle", gtag: @gtag).any?

    flash.now[:error] = t("alerts.credential.not_found", item: "Tag") if @gtag.nil?
    flash.now[:error] = t("alerts.credential.already_assigned", item: "Tag") if @gtag&.customer
    flash.now[:error] = t("alerts.credential.blacklisted", item: "Tag") if @gtag&.banned?
    flash.now[:error] = t("alerts.credential.invalid", item: "Tag") if recycle_present
    flash.now[:error] = t("alerts.credential.inactive", item: "Tag") unless @gtag&.active?
    render(:new) && return if flash.now[:error].present?

    @gtag.assign_customer(current_customer, current_customer)
    @gtag.assign_ticket_from_checkin
    @gtag.assign_replaced_gtags

    redirect_to event_path(@current_event), notice: t("alerts.credential.assigned", item: "Tag")
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
