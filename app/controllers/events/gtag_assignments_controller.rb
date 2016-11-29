class Events::GtagAssignmentsController < Events::BaseController
  before_action :check_event_status!
  before_action :check_has_not_gtag!, only: [:new, :create]

  def new
    @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)
  end

  def create # rubocop:disable Metrics/AbcSize
    gtag = current_event.gtags.where(tag_uid: permitted_params[:tag_uid].strip.upcase).order(:activation_counter).last
    @gtag_assignment_presenter = GtagAssignmentPresenter.new(current_event: current_event)

    flash.now[:error] = I18n.t("alerts.gtag.invalid") if gtag.nil?
    flash.now[:error] = I18n.t("alerts.gtag.already_assigned") if gtag&.customer
    render(:new) && return if flash.now[:error].present?

    gtag.update(customer: current_customer)
    create_transaction("gtag_assigned", gtag)
    redirect_to event_url(current_event), notice: I18n.t("alerts.created")
  end

  def destroy
    gtag = current_event.gtags.find(params[:id])
    gtag.update(customer: nil)
    create_transaction("gtag_unassigned", gtag)
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to event_url(current_event)
  end

  private

  def create_transaction(action, gtag)
    CredentialTransaction.create!(
      event: current_event,
      transaction_origin: Transaction::ORIGINS[:portal],
      action: action,
      customer_tag_uid: gtag.tag_uid,
      activation_counter: gtag.activation_counter,
      operator_tag_uid: current_customer.email,
      status_code: 0,
      status_message: "OK",
      device_created_at: Time.zone.now,
      device_created_at_fixed: Time.zone.now
    )
  end

  def check_event_status!
    return if current_event.gtag_assignation?
    redirect_to event_url(current_event), flash: { error: I18n.t("alerts.error") }
  end

  def check_has_not_gtag!
    return if current_customer.active_gtag.nil?
    redirect_to event_url(current_event), flash: { error: I18n.t("alerts.gtag_already_assigned") }
  end

  def permitted_params
    params.require(:gtag_assignment_form).permit(:tag_uid).merge(event_id: current_event.id)
  end
end
