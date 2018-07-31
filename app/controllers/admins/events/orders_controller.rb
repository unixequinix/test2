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

        items = atts[:order_items_attributes].to_h.values.select { |h| h["_destroy"].eql?("false") }.map { |h| [h["catalog_item_id"], h["amount"]] }
        items << [@alcohol_flag.id, 1] if alcohol_flag.to_i.eql?(1)
        items << [@topup_flag.id, 1] if topup_flag.to_i.eql?(1)

        @order = @customer.build_order(items, atts.slice(:money_base, :money_fee))
        authorize @order

        if @order.save
          @order.complete!("admin")
          redirect_to [:admins, @current_event, @order.customer], notice: t("alerts.created")
        else
          @catalog_items_collection = @current_event.catalog_items.not_user_flags.group_by { |item| item.type.underscore.humanize.pluralize }
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
        @order = @current_event.orders.includes(order_items: :catalog_item).find(params[:id])
        authorize @order
      end

      def set_other
        @alcohol_flag = @current_event.user_flags.find_or_create_by(name: "alcohol_forbidden")
        @topup_flag = @current_event.user_flags.find_or_create_by(name: "initial_topup")
        @customer = @current_event.customers.find(params[:customer_id] || params[:order][:customer_id])
      end

      def permitted_params
        params.require(:order).permit(:money_base, :money_fee, :customer_id, :alcohol_forbidden, :initial_topup, order_items_attributes: %i[id catalog_item_id amount _destroy])
      end
    end
  end
end
