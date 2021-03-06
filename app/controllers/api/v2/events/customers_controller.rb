module Api::V2
  class Events::CustomersController < BaseController
    before_action :set_customer, except: %i[index create]
    before_action :check_credits, only: %i[topup virtual_topup]

    # POST /events/:id/can_login
    def can_login
      render(status: :forbidden) && return if @customer.confirmed_at.nil?
      if @customer&.valid_password?(params[:password])
        render json: @customer
      else
        render status: :unauthorized
      end
    end

    def store_redirection
      render json: { store_path: @current_event.store_redirection(@customer, :topup) }
    end

    # POST api/v2/events/:event_id/customers/:id/ban
    def gtag_replacement
      old_gtag = @customer.active_gtag
      new_gtag = @current_event.gtags.find_or_initialize_by(tag_uid: params[:new_tag_uid])
      render(json: new_gtag.errors, status: :unprocessable_entity) && return unless new_gtag.validate_assignation
      render(json: { customer: "Has no current active Gtag" }, status: :unprocessable_entity) && return if old_gtag.nil?

      old_gtag.replace!(new_gtag)
      render json: @customer.reload, serializer: CustomerSerializer
    end

    # POST api/v2/events/:event_id/customers/:id/ban
    def ban
      @customer.credentials.map { |c| c.update(banned: true) }
      render json: @customer, serializer: CustomerSerializer
    end

    # POST api/v2/events/:event_id/customers/:id/unban
    def unban
      @customer.credentials.map { |c| c.update(banned: false) }
      render json: @customer, serializer: CustomerSerializer
    end

    # POST api/v2/events/:event_id/customers/:id/assign_gtag
    def assign_gtag
      params[:active] ||= "true"
      @code = params[:tag_uid].strip
      @gtag = @current_event.gtags.find_or_initialize_by(tag_uid: @code)

      render(json: @gtag.errors, status: :unprocessable_entity) && return unless @gtag.validate_assignation

      @gtag.assign_customer(@customer, @current_user) unless @gtag.customer == @customer
      @gtag.make_active! if params[:active].eql?("true")

      render json: @customer, serializer: CustomerSerializer
    end

    # POST api/v2/events/:event_id/customers/:id/assign_gtag
    def assign_ticket
      @code = params[:code].strip
      @ticket = @current_event.tickets.find_or_initialize_by(code: @code)
      render(json: @ticket.errors, status: :unprocessable_entity) && return unless @ticket.validate_assignation

      @ticket.assign_customer(@customer, @current_user) unless @ticket.customer == @customer
      render json: @customer, serializer: CustomerSerializer
    end

    # POST api/v2/events/:event_id/customers/:id/topup
    def topup
      credits = params[:credits].to_f
      @order = @customer.build_order([[@current_event.credit.id, credits]], params.permit(:money_base, :money_fee))

      if @order.save
        @order.complete!(params[:gateway], {}, params[:send_email])
        render json: @order, serializer: OrderSerializer
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/customers/:id/virtual_topup
    def virtual_topup
      credits = params[:credits].to_f
      @order = @customer.build_order([[@current_event.virtual_credit.id, credits]], params.permit(:money_base, :money_fee))

      if @order.save
        @order.complete!(params[:gateway], {}, params[:send_email])
        render json: @order, serializer: OrderSerializer
      else
        render json: @order.errors, status: :unprocessable_entity
      end
    end

    # POST api/v2/events/:event_id/customers/:id/refunds
    def refund
      fee = @current_event.online_refund_fee.to_f
      base = @customer.credits - fee
      params[:gateway] ||= "other"

      @refund = @current_event.refunds.new(credit_base: base, credit_fee: fee, customer: @customer, gateway: params[:gateway])
      if @refund.save
        @refund.complete!(params[:send_email])
        render json: @refund, status: :created, location: [:admins, @current_event, @refund]
      else
        render json: @refund.errors, status: :unprocessable_entity
      end
    end

    # GET api/v2/events/:event_id/customers/:id/refunds
    def refunds
      @refunds = @customer.refunds
      render json: @refunds, each_serializer: RefundSerializer
    end

    def transactions
      render json: @customer, serializer: CustomerTransactionsSerializer
    end

    # GET api/v2/events/:event_id/customers
    def index
      @customers = @current_event.customers.includes(:refunds, orders: :order_items, gtags: { ticket_type: :catalog_item }, tickets: { ticket_type: :catalog_item })
      authorize @customers

      paginate json: @customers, each_serializer: CustomerSerializer
    end

    # GET api/v2/events/:event_id/customers/:id
    def show
      render json: @customer, serializer: CustomerSerializer
    end

    # POST api/v2/events/:event_id/customers
    def create
      new_params = customer_params.merge(anonymous: false, agreed_on_registration: true)
      new_params[:password_confirmation] = new_params[:password]
      new_params[:encrypted_password] = SecureRandom.hex(24) if new_params[:password].blank? && new_params[:password_confirmation].blank?

      @customer = @current_event.customers.new(new_params)
      @customer.skip_confirmation! unless JSON.parse(customer_params[:confirmation] || false) # TODO[fmoya] Ana's project hack to send email on user creation
      authorize @customer

      if @customer.save
        render json: @customer, serializer: CustomerSerializer, status: :created, location: [:admins, @current_event, @customer]
      else
        render json: @customer.errors, status: :unprocessable_entity
      end
    end

    # PATCH/PUT api/v2/events/:event_id/customers/:id
    def update
      if @customer.update(customer_params)
        render json: @customer, serializer: CustomerSerializer
      else
        render json: @customer.errors, status: :unprocessable_entity
      end
    end

    # DELETE api/v2/events/:event_id/customers/:id
    def destroy
      @customer.destroy
      head(:ok)
    end

    private

    def check_credits
      render(json: { credits: "Must be present and positive" }, status: :unprocessable_entity) unless params[:credits].to_f.positive?
    end

    def set_customer
      customers = @current_event.customers
      customer_id = customers.find_by(id: params[:id])&.id || customers.find_by(email: params[:id])&.id

      @customer = customers.find(customer_id)
      authorize @customer
    end

    # Only allow a trusted parameter "white list" through.
    def customer_params
      params.require(:customer).permit(:first_name, :last_name, :email, :phone, :birthdate, :postcode, :address, :city, :country, :gender, :password, :confirmation)
    end
  end
end
