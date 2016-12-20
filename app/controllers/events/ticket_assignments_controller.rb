class Events::TicketAssignmentsController < Events::BaseController
  def create
    @code = permitted_params[:code].strip
    @ticket = @current_event.tickets.find_by(code: @code)
    render(:new) && return unless can_assign?(@ticket)

    @ticket.update!(customer: current_customer)
    create_transaction("ticket_assigned")
    redirect_to(customer_root_path(@current_event), notice: I18n.t("alerts.ticket_assigned"))
  end

  def destroy
    @ticket = @current_event.tickets.find(params[:id])
    create_transaction("ticket_unassigned")
    @ticket.update!(customer: nil)
    redirect_to customer_root_path(@current_event), notice: I18n.t("alerts.unassigned")
  end

  private

  def create_transaction(action)
    atts = { ticket: @ticket }
    Transaction.write!(@current_event, CredentialTransaction, action, :portal, current_customer, current_admin, atts)
  end

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
