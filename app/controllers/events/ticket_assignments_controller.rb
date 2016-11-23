class Events::TicketAssignmentsController < Events::BaseController
  def create # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    @code = permitted_params[:code].strip
    @ticket = current_event.tickets.find_by(code: @code)

    if @ticket.blank?
      flash.now[:error] = I18n.t("alerts.admissions")
      render(:new) && return
    end

    if @ticket.ticket_type&.catalog_item.nil?
      flash.now[:error] = I18n.t("alerts.ticket_without_credential")
      render(:new) && return
    end

    if @ticket.banned?
      flash.now[:error] = I18n.t("alerts.ticket_banned")
      render(:new) && return
    end

    if @ticket.customer
      flash.now[:error] = I18n.t("alerts.ticket_already_assigned")
      render(:new) && return
    end

    @ticket.update!(customer: current_customer)
    redirect_to(customer_root_path(current_event), notice: I18n.t("alerts.ticket_assigned"))
  end

  def destroy
    ticket = current_event.tickets.find(params[:id])
    ticket.update!(customer: nil)
    redirect_to customer_root_path(current_event), notice: I18n.t("alerts.unassigned")
  end

  private

  def permitted_params
    params.require(:ticket).permit(:code)
  end
end
