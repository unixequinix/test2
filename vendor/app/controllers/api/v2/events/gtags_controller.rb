module Api::V2
  class Events::GtagsController < BaseController
    before_action :set_gtag, only: %i[virtual_topup topup show update destroy ban unban]
    before_action :check_credits, only: %i[topup virtual_topup]

    # POST api/v2/events/:event_id/gtags/:id/replace
    def replace
      new_gtag = @current_event.gtags.find_or_initialize_by(tag_uid: params[:new_tag_uid])
      render(json: new_gtag.errors, status: :unprocessable_entity) && return unless new_gtag.validate_assignation

      @gtag.replace!(new_gtag)
      render json: new_gtag, serializer: GtagSerializer
    end

    # POST api/v2/events/:event_id/gtags/:id/ban
    def ban
      if @gtag.update(banned: true)
        render json: @gtag
      else
        render json: @gtag.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/gtags/:id/unban
    def unban
      if @gtag.update(banned: false)
        render json: @gtag
      else
        render json: @gtag.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/gtags/:id/topup
    def topup
      @gtag.update!(customer: @current_event.customers.create!) if @gtag.customer.blank?

      @order = @gtag.customer.build_order([[@current_event.credit.id, params[:credits]]], params.permit(:money_base, :money_fee))

      if @order.save
        @order.complete!(params[:gateway], {}, params[:send_email])
        render json: @order, serializer: OrderSerializer
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/gtags/:id/virtual_topup
    def virtual_topup
      @gtag.update!(customer: @current_event.customers.create!) if @gtag.customer.blank?

      @order = @gtag.customer.build_order([[@current_event.virtual_credit.id, params[:credits]]], params.permit(:money_base, :money_fee))

      if @order.save
        @order.complete!(params[:gateway], {}, params[:send_email])
        render json: @order, serializer: OrderSerializer
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # GET api/v2/events/:event_id/gtags
    def index
      @gtags = @current_event.gtags
      authorize @gtags

      render json: @gtags, each_serializer: Simple::GtagSerializer
    end

    # GET api/v2/events/:event_id/gtags/:id
    def show
      render json: @gtag, serializer: GtagSerializer
    end

    # POST api/v2/events/:event_id/gtags
    def create
      @gtag = @current_event.gtags.new(gtag_params)
      authorize @gtag

      if @gtag.save
        render json: @gtag, status: :created, location: [:admins, @current_event, @gtag]
      else
        render json: @gtag.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT api/v2/events/:event_id/gtags/:id
    def update
      if @gtag.update(gtag_params)
        render json: @gtag
      else
        render json: @gtag.errors, status: :unprocessable_entity
      end
    end

    # DELETE api/v2/events/:event_id/gtags/:id
    def destroy
      @gtag.destroy
      head(:ok)
    end

    private

    def check_credits
      render(json: { credits: "Must be present and positive" }, status: :unprocessable_entity) unless params[:credits].to_f.positive?
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_gtag
      gtags = @current_event.gtags

      Rollbar.silenced do
        gtag_id = gtags.find_by(id: params[:id])&.id || gtags.find_by(tag_uid: params[:id])&.id

        @gtag = gtags.find(gtag_id)
        authorize @gtag
      end
    end

    # Only allow a trusted parameter "white list" through.
    def gtag_params
      params.require(:gtag).permit(:tag_uid, :banned, :customer_id, :redeemed, :ticket_type_id)
    end
  end
end
