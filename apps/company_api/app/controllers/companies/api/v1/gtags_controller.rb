class Companies::Api::V1::GtagsController < Companies::Api::V1::BaseController
  def index
    @gtags = @fetcher.gtags

    render json: {
      event_id: current_event.id,
      gtags: @gtags.map { |gtag| Companies::Api::V1::GtagSerializer.new(gtag) }
    }
  end

  def show
    @gtag = @fetcher.gtags.find_by(id: params[:id])

    if @gtag
      render json: @gtag, serializer: Companies::Api::V1::GtagSerializer
    else
      render(status: :not_found,
             json: { status: "not_found", error: "Gtag with id #{params[:id]} not found." })
    end
  end

  def create
    @gtag = Gtag.new(gtag_params.merge(event: current_event))

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity", error: "Ticket type not found." }) &&
      return unless validate_gtag_type!

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity",
                   error: @gtag.errors.full_messages }) && return unless @gtag.save

    render status: :created, json: Companies::Api::V1::GtagSerializer.new(@gtag)
  end

  def update
    @gtag = @fetcher.gtags.find_by(id: params[:id])

    update_params = gtag_params
    purchaser_attributes = update_params[:purchaser_attributes]
    purchaser_attributes.merge!(id: @gtag.purchaser.id) if purchaser_attributes

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity",
                   error: "The ticket type doesn't belongs to your company" }) &&
      return unless validate_gtag_type!

    render(status: :unprocessable_entity,
           json: { status: "unprocessable_entity", errors: @gtag.errors.full_messages }) &&
      return unless @gtag.update(update_params)

    render json: Companies::Api::V1::GtagSerializer.new(@gtag)
  end

  private

  def gtag_params
    ticket_type = params[:gtag][:ticket_type_id]
    params[:gtag][:company_ticket_type_id] = ticket_type if ticket_type

    params.require(:gtag).permit(:tag_uid,
                                 :company_ticket_type_id,
                                 purchaser_attributes: [:id, :first_name, :last_name, :email])
  end
end
