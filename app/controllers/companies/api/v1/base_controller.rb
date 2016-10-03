class Companies::Api::V1::BaseController < Companies::BaseController
  attr_reader :current_event, :agreement
  before_action :restrict_access_with_http
  before_action :api_enabled, except: [:restrict_access_with_http]

  private

  def restrict_access_with_http
    authenticate_or_request_with_http_basic do |event_token, company_token|
      @current_event = Event.find_by(token: event_token)

      @agreement = @current_event&.company_event_agreements
                                 &.includes(:company)
                                 &.find_by(companies: { access_token: company_token })

      @current_event && @agreement || render(status: 403, json: :unauthorized)
    end
  end

  def api_enabled
    return if @current_event.thirdparty_api?
    render(status: :unauthorized, json: :unauthorized)
  end

  def validate_ticket_type!
    ticket_type_id = params[:ticket][:company_ticket_type_id]
    return true unless ticket_type_id
    ticket_type = CompanyTicketType.find_by(id: ticket_type_id)
    ticket_type && ticket_type.company_event_agreement == agreement &&
      ticket_type.event == current_event && ticket_type.deleted_at.nil?
  end

  def validate_gtag_type!
    ticket_type_id = params[:gtag][:company_ticket_type_id]
    return true unless ticket_type_id
    ticket_type = CompanyTicketType.find_by(id: params[:gtag][:ticket_type_id])
    ticket_type && ticket_type.company_event_agreement == agreement &&
      ticket_type.event == current_event && ticket_type.deleted_at.nil?
  end

  private

  def company_ticket_types
    current_event.company_ticket_types.where(company_event_agreement: @agreement.id)
  end

  def tickets
    current_event.tickets
                 .joins(company_ticket_type: :company_event_agreement)
                 .where(company_ticket_types: { company_event_agreement_id: @agreement.id })
                 .joins("LEFT OUTER JOIN purchasers
                         ON purchasers.credentiable_id = tickets.id
                         AND purchasers.credentiable_type = 'Ticket'
                         AND purchasers.deleted_at IS NULL")
                 .includes(:purchaser)
  end

  def banned_tickets
    tickets.where(banned: true)
  end
end
