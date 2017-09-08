class Api::V2::Events::RefundsController < Api::V2::BaseController
  before_action :set_refund, only: %i[show update destroy complete]

  # PATCH/PUT /refunds/1
  def complete
    if @refund.completed?
      @refund.errors.add(:status, "is already completed")
      render json: @refund.errors, status: :unprocessable_entity
    else
      @refund.complete!(refund_params[:refund_data])
      render json: @refund
    end
  end

  # GET /refunds
  def index
    @refunds = @current_event.refunds
    authorize @refunds

    render json: @refunds
  end

  # GET /refunds/1
  def show
    render json: @refund
  end

  # POST /refunds
  def create
    @refund = @current_event.refunds.new(refund_params)
    authorize @refund

    if @refund.save
      render json: @refund, status: :created, location: [:admins, @current_event, @refund]
    else
      render json: @refund.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /refunds/1
  def update
    if @refund.update(refund_params)
      render json: @refund
    else
      render json: @refund.errors, status: :unprocessable_entity
    end
  end

  # DELETE /refunds/1
  def destroy
    @refund.destroy
    head(:ok)
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_refund
    @refund = @current_event.refunds.find(params[:id])
    authorize @refund
  end

  # Only allow a trusted parameter "white list" through.
  def refund_params
    params.require(:refund).permit(:amount, :status, :fee, :field_a, :field_b, :customer_id, :gateway, :refund_data)
  end
end
