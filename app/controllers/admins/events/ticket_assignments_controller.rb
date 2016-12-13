class Admins::Events::TicketAssignmentsController < Admins::Events::BaseController
  before_action :set_customer, only: [:new, :create]

  # rubocop:disable Metrics/AbcSize
  def create
    @code = permitted_params[:code].strip
    @ticket = current_event.tickets.find_by(code: @code)

    errors = []
    errors << I18n.t("alerts.admissions") if @ticket.blank?
    errors << I18n.t("alerts.ticket_without_credential") if @ticket.ticket_type&.catalog_item.nil?
    errors << I18n.t("alerts.ticket_banned") if @ticket.banned?
    errors << I18n.t("alerts.ticket_already_assigned") if @ticket.customer

    if errors.any?
      flash.now[:errors] = errors.to_sentence
      render(:new)
    else
      @ticket.update!(customer: @customer)
      create_transaction("ticket_assigned", @ticket)
      redirect_to(admins_event_customer_path(current_event, @customer), notice: I18n.t("alerts.ticket_assigned"))
    end
  end

  def destroy
    ticket = Ticket.find(params[:id])
    create_transaction("ticket_unassigned", ticket)
    ticket.update!(customer: nil)

    flash[:notice] = I18n.t("alerts.unassigned")
    redirect_to :back
  end

  private

  def set_customer
    @customer = current_event.customers.find(params[:id])
  end

  def create_transaction(action, ticket)
    customer = ticket.customer
    CredentialTransaction.create!(
      event: current_event,
      transaction_origin: Transaction::ORIGINS[:admin],
      action: action,
      ticket: ticket,
      station: current_event.portal_station,
      customer: customer,
      counter: customer.transactions.maximum(:counter).to_i + 1,
      operator_tag_uid: current_admin.email,
      status_code: 0,
      status_message: "OK",
      device_created_at: Time.zone.now,
      device_created_at_fixed: Time.zone.now
    )
  end

  def permitted_params
    params.permit(:code).merge(event_id: current_event.id)
  end
end
