class Events::OrdersController < Events::EventsController
  before_action :set_order, except: %i[new create]

  def show
    @payment_gateways = @current_event.payment_gateways.topup
    redirect_to @current_event, notice: t("orders.already_finalised") unless @order.in_progress?
  end

  def new
    redirect_to @current_event unless @current_event.open_topups
    @order = @current_customer.orders.new
    @catalog_items = catalog_items_hash
  end

  def create
    items = params[:checkout_form][:catalog_items].permit!.to_h.to_a
    @order = @current_customer.build_order(items, ip: request.remote_ip)

    if @order.order_items.any? && @order.save
      redirect_to event_order_path(@current_event, @order)
    else
      @catalog_items = catalog_items_hash
      flash.now[:error] = @order.errors.full_messages.to_sentence
      render :new
    end
  end

  def complete
    @order.complete!("none", {}, true)
    redirect_to success_event_order_path(@current_event, @order)
  end

  private

  def set_order
    @order = @current_event.orders.includes(order_items: :catalog_item).find(params[:id])
  end

  def catalog_items_hash
    portal_items = @current_event.portal_station.station_catalog_items
    CatalogItem.joins(:station_catalog_items)
               .select("catalog_items.*, station_catalog_items.price")
               .where.not(id: @current_customer.infinite_accesses_purchased)
               .where(station_catalog_items: { hidden: false, id: portal_items.ids })
               .includes(:event)
               .group_by(&:type)
  end
end
