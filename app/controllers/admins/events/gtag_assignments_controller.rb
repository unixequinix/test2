class Admins::Events::GtagAssignmentsController < Admins::Events::BaseController
  def new
    @customer = current_event.customers.find(params[:id])
  end

  # rubocop:disable Metrics/AbcSize
  def create
    @customer = current_event.customers.find(params[:id])
    gtag = current_event.gtags.find_by(tag_uid: permitted_params[:tag_uid].strip.upcase)

    flash.now[:error] = I18n.t("alerts.gtag.invalid") if gtag.nil?
    flash.now[:error] = I18n.t("alerts.gtag.already_assigned") if gtag&.customer
    render(:new) && return unless flash.now[:error].blank?

    gtag.update(active: permitted_params[:active].present?)
    @customer.gtags.update_all(active: false) if gtag.active?
    @customer.gtags << gtag
    create_transaction("gtag_assigned", gtag)
    redirect_to admins_event_customer_url(current_event, @customer), notice: I18n.t("alerts.created")
  end

  def destroy
    gtag = Gtag.find(params[:id])
    gtag.update(customer: nil)

    create_transaction("gtag_unassigned", gtag)
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def create_transaction(action, gtag)
    CredentialTransaction.create!(
      event: current_event,
      transaction_origin: Transaction::ORIGINS[:admin],
      transaction_category: "credential",
      action: action,
      customer_tag_uid: gtag.tag_uid,
      activation_counter: gtag.activation_counter,
      operator_tag_uid: current_admin.email,
      status_code: 0,
      status_message: "OK",
      device_created_at: Time.zone.now,
      device_created_at_fixed: Time.zone.now
    )
  end

  def permitted_params
    params.permit(:tag_uid, :active).merge(event_id: current_event.id)
  end
end
