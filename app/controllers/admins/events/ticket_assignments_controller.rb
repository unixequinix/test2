class Admins::Events::TicketAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: [:new, :create]

  def new
    authorize @customer, :new_credential?
  end

  def create
    authorize @customer, :create_credential?
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_by(code: @code)

    errors = []
    errors << t("alerts.alerts.not_found", item: "Ticket") if @ticket.blank?
    errors << t("alerts.credentail.without_credential") if @ticket&.ticket_type&.catalog_item.nil?
    errors << t("alerts.credentail.already_assigned", item: "Ticket") if @ticket&.customer

    if errors.any?
      flash.now[:errors] = errors.to_sentence
      render(:new)
    else
      @ticket.assign_customer(@customer, :admin, current_user)
      redirect_to(admins_event_customer_path(@current_event, @customer), notice: t("alerts.credential.assigned", item: "Ticket"))
    end
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    authorize @ticket.customer, :destroy_credential?
    @ticket.unassign_customer(:admin, current_user)
    flash[:notice] = t("alerts.credential.unassigned", item: "Ticket")
    redirect_to :back
  end

  private

  def set_customer
    @customer = @current_event.customers.find(params[:id])
  end

  def permitted_params
    params.permit(:code).merge(event_id: @current_event.id)
  end
end
