class Admins::Events::GtagAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: %i[new create]

  def new
    authorize @customer, :new_credential?
  end

  def create
    authorize @customer, :create_credential?

    @gtag = @current_event.gtags.find_by(tag_uid: permitted_params[:tag_uid].strip.upcase)

    errors = []
    errors << t("alerts.credential.not_found", item: "Gtag") if @gtag.blank?
    errors << t("alerts.credential.already_assigned", item: "Gtag") if @gtag&.customer

    if errors.any?
      flash.now[:errors] = errors.to_sentence
      render(:new)
    else
      @gtag.update(active: permitted_params[:active].present?)
      @customer.gtags.update_all(active: false) if @gtag.active?
      @gtag.assign_customer(@customer, current_user, :admin)
      redirect_to admins_event_customer_path(@current_event, @customer), notice: t("alerts.credential.assigned", item: "Gtag")
    end
  end

  def destroy
    @gtag = @current_event.gtags.find(params[:id])
    authorize @gtag.customer, :destroy_credential?
    @gtag.unassign_customer(current_user, :admin)
    flash[:notice] = t("alerts.credential.unassigned", item: "Gtag")
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
