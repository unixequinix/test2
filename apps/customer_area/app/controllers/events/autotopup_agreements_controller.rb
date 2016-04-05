class Events::AutotopupAgreementsController < Events::BaseController
  def new
    @ticket_assignment_form = TicketAssignmentForm.new
  end

  def create
    @ticket_assignment_form = TicketAssignmentForm.new(ticket_assignment_parameters)
    if @ticket_assignment_form.save(Ticket.where(event: current_event),
                                    current_profile,
                                    current_event)
      flash[:notice] = I18n.t("alerts.created")
      redirect_to event_url(current_event)
    else
      flash.now[:error] = @ticket_assignment_form.errors.full_messages.join
      render :new
    end
  end

  def destroy
    @payment_gateway_customer = PaymentGatewayCustomer.find(params[:id])
    if @payment_gateway_customer.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to event_url(current_event)
    else
      flash[:error] = @payment_gateway_customer.errors.full_messages.join(". ")
      redirect_to edit_event_registrations_url(current_event)
    end
  end

  private

  def ticket_assignment_parameters
    params.require(:ticket_assignment_form).permit(:code)
  end
end
