class Events::TicketAssignmentsController < Events::BaseController
  def create
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_by(code: @code)
    render(:new) && return unless can_assign?(@ticket)

    @ticket.assign_customer(current_customer, :portal, current_customer)
    redirect_to(customer_root_path(@current_event), notice: I18n.t("alerts.ticket_assigned"))
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    @ticket.unassign_customer(:portal, current_customer)
    redirect_to customer_root_path(@current_event), notice: I18n.t("alerts.unassigned")
  end

  private

  def can_assign?(ticket)
    flash.now[:error] = case
                          when ticket.blank? then I18n.t("alerts.admissions")
                          when ticket.ticket_type&.catalog_item.nil? then I18n.t("alerts.ticket_without_credential")
                          when ticket.banned? then I18n.t("alerts.ticket_banned")
                          when ticket.customer then I18n.t("alerts.ticket_already_assigned")
                        end

    flash.now[:error].nil?
  end

  def permitted_params
    params.require(:ticket).permit(:code)
  end
end
