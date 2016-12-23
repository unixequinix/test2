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
    @gtag.assign_customer(@customer, :admin, current_admin)
    redirect_to admins_event_customer_url(@current_event, @customer), notice: I18n.t("alerts.created")
  end

  def destroy
    @gtag = Gtag.find(params[:id])
    @gtag.unassign_customer(:admin, current_admin)
    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def set_customer
    @customer = @current_event.customers.find(params[:id])
  end

  def permitted_params
    params.permit(:tag_uid, :active).merge(event_id: @current_event.id)
  end
end
