class Admins::Events::GtagAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: %i[new create]

  def new
    authorize @customer, :new_credential?
    @gtag = @customer.gtags.new(active: true)
  end

  def create
    authorize @customer, :create_credential?
    @code = permitted_params[:code].strip
    @gtag = @current_event.gtags.find_or_initialize_by(code: @code)

    @gtag.errors.add(:reference, I18n.t("credentials.already_assigned", item: "Tag")) if @gtag.customer_not_anonymous?

    if @gtag.validate_assignation
      @gtag.assign_customer(@customer, current_user, :admin)
      redirect_to(admins_event_customer_path(@current_event, @customer), notice: t("credentials.assigned", item: "Tag"))
    else
      flash.now[:errors] = errors.to_sentence
      render(:new)
    end
  end

  def destroy
    @gtag = @current_event.gtags.find(params[:id])
    authorize @gtag.customer, :destroy_credential?
    @gtag.unassign_customer(current_user, :admin)
    flash[:notice] = t("credentials.unassigned", item: "Gtag")
    redirect_to request.referer
  end

  private

  def set_customer
    @customer = @current_event.customers.find(params[:id])
  end

  def permitted_params
    params.require(:gtag).permit(:tag_uid, :ticket_type_id, :active, :event_id)
  end
end
