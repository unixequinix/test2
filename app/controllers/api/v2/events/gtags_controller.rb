class Api::V2::Events::GtagsController < Api::V2::BaseController
  before_action :set_gtag, only: %i[topup show update destroy]

  # POST /customers/:id/topup
  def topup
    @gtag.update!(customer: @current_event.customers.create!) if @gtag.customer.blank?

    @order = @gtag.customer.build_order([[@current_event.credit.id, params[:credits]]])

    if @order.save
      @order.complete!(params[:gateway])
      render json: @order, serializer: Api::V2::OrderSerializer
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # GET /gtags
  def index
    @gtags = @current_event.gtags

    render json: @gtags, each_serializer: Api::V2::Simple::GtagSerializer
  end

  # GET /gtags/1
  def show
    render json: @gtag
  end

  # POST /gtags
  def create
    @gtag = @current_event.gtags.new(gtag_params)

    if @gtag.save
      render json: @gtag, status: :created, location: [:admins, @current_event, @gtag]
    else
      render json: @gtag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /gtags/1
  def update
    if @gtag.update(gtag_params)
      render json: @gtag
    else
      render json: @gtag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /gtags/1
  def destroy
    @gtag.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_gtag
    @gtag = @current_event.gtags.find_by(id: params[:id]) || @current_event.gtags.find_by(tag_uid: params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def gtag_params
    params.require(:gtag).permit(:tag_uid, :banned, :active, :credits, :refundable_credits, :final_balance, :final_refundable_balance, :customer_id, :redeemed, :ticket_type_id) # rubocop:disable Metrics/LineLength
  end
end
