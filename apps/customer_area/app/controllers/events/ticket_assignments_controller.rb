class Events::TicketAssignmentsController < Events::BaseController
  def new
    @ticket_assignment_form = TicketAssignmentForm.new
  end

  def create
    @ticket_assignment_form = TicketAssignmentForm.new(ticket_assignment_parameters)
    if @ticket_assignment_form.save(Ticket.where(event: current_event), current_customer_event_profile, current_event)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to event_url(current_event)
    else
      flash[:error] = @ticket_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    @ticket_assignment = CredentialAssignment.find(params[:id])
    @ticket_assignment.unassign!

    @credit_log = CreditLog.create(
      customer_event_profile_id: current_customer_event_profile.id,
      transaction_type: CreditLog::TICKET_UNASSIGNMENT,
      amount: -preevent_product_items_credits.sum(:amount)
    ) unless preevent_product_items_credits.blank?

    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to event_url(current_event)
  end

  private

  def ticket_assignment_parameters
    params.require(:ticket_assignment_form).permit(:code)
  end

  def preevent_product_items_credits
    @ticket_assignment.credentiable
      .company_ticket_type.preevent_product
      .preevent_product_items
      .joins(:preevent_item)
      .where(preevent_items: { purchasable_type: "Credit" })
  end
end
