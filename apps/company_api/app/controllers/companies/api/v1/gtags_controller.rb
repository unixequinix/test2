class Companies::Api::V1::GtagsController < Companies::Api::V1::BaseController
  def index
    @gtags = Gtag.search_by_company_and_event(current_company.name, current_event)

    render json: {
      event_id: current_event.id,
      gtags: @gtags.map { |gtag| Companies::Api::V1::GtagSerializer.new(gtag) }
    }
  end

  def show
    @gtag = Gtag.search_by_company_and_event(current_company.name, current_event)
            .find_by(id: params[:id])

    if @gtag
      render json: @gtag
    else
      render status: :not_found,
             json: { error: I18n.t("company_api.gtags.not_found", gtag_id: params[:id]) }
    end
  end

  def create
    @gtag = Gtag.new(gtag_params.merge(event: current_event))

    render(status: :bad_request,
           json: {
             error: I18n.t("company_api.gtags.ticket_type_error")
           }) && return unless validate_gtag_type!

    render(status: :bad_request,
           json: { message: I18n.t("company_api.gtags.bad_request"),
                   errors: @gtag.errors }) && return unless @gtag.save

    render status: :created, json: Companies::Api::V1::GtagSerializer.new(@gtag)
  end

  def update
    @gtag = Gtag.search_by_company_and_event(current_company.name, current_event)
            .find_by(id: params[:id])

    update_params = gtag_params
    purchaser_attributes = update_params[:purchaser_attributes]
    purchaser_attributes.merge!(id: @gtag.purchaser.id) if purchaser_attributes

    render(status: :bad_request,
           json: {
             error: I18n.t("company_api.gtags.ticket_type_error")
           }) && return unless validate_gtag_type!

    render(status: :bad_request,
           json: { message: I18n.t("company_api.gtags.bad_request"),
                   errors: @gtag.errors }) && return unless @gtag.update(update_params)

    render json: Companies::Api::V1::GtagSerializer.new(@gtag)
  end

  private

  def gtag_params
    ticket_type = params[:gtag][:ticket_type_id]
    params[:gtag][:company_ticket_type_id] = ticket_type if ticket_type

    params.require(:gtag).permit(:tag_serial_number,
                                 :tag_uid,
                                 :company_ticket_type_id,
                                 purchaser_attributes: [:id, :first_name, :last_name, :email])
  end
end
