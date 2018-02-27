module Api::V2
  class Events::RefundsController < BaseController
    before_action :set_refund, only: %i[show update destroy complete cancel]

    # PATCH/PUT api/v2/events/:event_id/refunds/:id
    def complete
      if @refund.completed?
        @refund.errors.add(:status, "is already completed")
        render json: @refund.errors, status: :unprocessable_entity
      else
        @refund.complete!(params[:send_email])
        render json: @refund
      end
    end

    # PATCH/PUT api/v2/events/:event_id/refunds/:id
    def cancel
      if @refund.cancelled?
        @refund.errors.add(:status, "is already cancelled")
        render json: @refund.errors, status: :unprocessable_entity
      else
        @refund.cancel!(params[:send_email])
        render json: @refund
      end
    end

    # GET api/v2/events/:event_id/refunds
    def index
      @refunds = @current_event.refunds
      authorize @refunds

      paginate json: @refunds
    end

    # GET api/v2/events/:event_id/refunds/:id
    def show
      render json: @refund, serializer: RefundSerializer
    end

    # POST api/v2/events/:event_id/refunds
    def create
      params[:refund][:gateway] ||= "other"
      @refund = @current_event.refunds.new(refund_params)
      authorize @refund

      if @refund.save
        render json: @refund, status: :created, location: [:admins, @current_event, @refund]
      else
        render json: @refund.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT api/v2/events/:event_id/refunds/:id
    def update
      if @refund.update(refund_params)
        render json: @refund
      else
        render json: @refund.errors, status: :unprocessable_entity
      end
    end

    # DELETE api/v2/events/:event_id/refunds/:id
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
      params.require(:refund).permit(:credit_base, :credit_fee, :customer_id, :gateway, fields: {})
    end
  end
end
