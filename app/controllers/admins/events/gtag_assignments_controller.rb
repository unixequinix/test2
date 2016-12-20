class Admins::Events::GtagAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: [:new, :create]

  # rubocop:disable Metrics/AbcSize
  def create
    @gtag = @current_event.gtags.find_by(tag_uid: permitted_params[:tag_uid].strip.upcase)

    flash.now[:error] = I18n.t("alerts.gtag.invalid") if @gtag.nil?
    flash.now[:error] = I18n.t("alerts.gtag.already_assigned") if @gtag&.customer
    render(:new) && return unless flash.now[:error].blank?

    @gtag.update(active: permitted_params[:active].present?)
    @customer.gtags.update_all(active: false) if @gtag.active?
    @customer.gtags << @gtag
    create_transaction("gtag_assigned")
    redirect_to admins_event_customer_url(@current_event, @customer), notice: I18n.t("alerts.created")
  end

  def destroy
    @gtag = Gtag.find(params[:id])
    create_transaction("gtag_unassigned")
    @gtag.update(customer: nil)
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def create_transaction(action)
    atts = { customer_tag_uid: @gtag.tag_uid }
    Transaction.write!(@current_event, CredentialTransaction, action, :admin, current_customer, current_admin, atts)
  end

  def set_customer
    @customer = @current_event.customers.find(params[:id])
  end

  def permitted_params
    params.permit(:tag_uid, :active).merge(event_id: @current_event.id)
  end
end
