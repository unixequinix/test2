class Admins::Events::TicketAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: %i[new create]

  def new
    authorize @customer, :new_credential?
  end

  def create
    authorize @customer, :create_credential?
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_or_initialize_by(code: @code)

    @ticket.errors.add(:reference, I18n.t("credentials.already_assigned", item: "Ticket")) if @ticket.customer_not_anonymous?

    if @ticket.validate_assignation
      @ticket.assign_customer(@customer, current_user, :admin)
      redirect_to(admins_event_customer_path(@current_event, @customer), notice: t("credentials.assigned", item: "Ticket"))
    else
      flash.now[:errors] = @ticket.errors.full_messages.to_sentence
      render(:new)
    end
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    authorize @ticket.customer, :destroy_credential?
    @ticket.unassign_customer(current_user, :admin)
    flash[:notice] = t("credentials.unassigned", item: "Ticket")
    redirect_to request.referer
  end

  private

  def set_customer
    @customer = @current_event.customers.find(params[:id])
  end

  def permitted_params
    params.permit(:code).merge(event_id: @current_event.id)
  end
end
