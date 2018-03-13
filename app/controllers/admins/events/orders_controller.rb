module Admins
  module Events
    class OrdersController < Admins::Events::BaseController
      before_action :set_order, only: %i[show destroy]
      before_action :set_other, only: %i[new create]

      def index
        @orders = @current_event.orders.includes(order_items: :catalog_item).order(id: :desc)
        authorize @orders
        @orders = @orders.page(params[:page])
        @counts = @current_event.orders.group(:status).count

        @graph = %w[in_progress completed cancelled failed].map do |action|
          data = OrderItem.where(order: @current_event.orders.where(status: action)).group_by_day(:created_at).sum(:amount)
          data = data.collect { |k, v| [k, v.to_i.abs] }
          { name: action, data: Hash[data] }
        end
      end

      def show; end

      def new
        @catalog_items_collection = @current_event.catalog_items.not_user_flags.group_by { |item| item.type.underscore.humanize.pluralize }
        @order = @current_event.orders.new(customer: @customer)
        authorize @order
      end

      def create
        atts = permitted_params.dup
        alcohol_flag = atts.delete(:alcohol_forbidden)
        topup_flag = atts.delete(:initial_topup)
        @order = @current_event.orders.new(atts)
        @order.order_items.build(catalog_item: @alcohol_flag, amount: 1) if alcohol_flag.to_i.eql?(1)
        @order.order_items.build(catalog_item: @topup_flag, amount: 1) if topup_flag.to_i.eql?(1)
        authorize @order

        if @order.set_counters.save
          @order.update(gateway: "admin", status: "completed", completed_at: Time.zone.now)
          redirect_to [:admins, @current_event, @order.customer], notice: t("alerts.created")
        else
          @catalog_items_collection = @current_event.catalog_items.not_user_flags.group_by { |item| item.type.underscore.humanize.pluralize }
          @order.order_items.build(catalog_item: @alcohol_flag, amount: alcohol_flag) if alcohol_flag.to_i.eql?(1)
          @order.order_items.build(catalog_item: @topup_flag, amount: topup_flag) if topup_flag.to_i.eql?(1)
          flash.now[:alert] = t("alerts.error")
          render :new
        end
      end

      def destroy
        message = @order.destroy ? { notice: t('alerts.destroyed') } : { alert: @order.errors.full_messages.join(",") }
        redirect_to request.referer, message
      end

      private

      def set_order
        @order = @current_event.orders.includes(catalog_items: :event).find(params[:id])
        authorize @order
      end

      def set_other
        @alcohol_flag = @current_event.user_flags.find_or_create_by(name: "alcohol_forbidden")
        @topup_flag = @current_event.user_flags.find_or_create_by(name: "initial_topup")
        @customer = @current_event.customers.find(params[:customer_id] || params[:order][:customer_id])
      end

      def permitted_params
        params.require(:order).permit(:money_base, :money_fee, :status, :customer_id, :credits, :alcohol_forbidden, :initial_topup, order_items_attributes: %i[id catalog_item_id amount _destroy])
      end
    end
  end
end
