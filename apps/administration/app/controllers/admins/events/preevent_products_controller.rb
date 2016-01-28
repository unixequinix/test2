class Admins::Events::PreeventProductsController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @preevent_product = PreeventProduct.new
    @preevent_items_collection = @fetcher.preevent_items
  end

  def create
    @preevent_product = PreeventProduct.new(permitted_params)
    binding.pry
    if @preevent_product.save
      binding.pry
      update_preevent_items_counter(permitted_params[:preevent_item_ids])
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_preevent_products_url
    else
      @preevent_items_collection = @fetcher.preevent_items
      flash[:error] = @preevent_product.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @preevent_product = @fetcher.preevent_products.find(params[:id])
    @preevent_items_collection = @fetcher.preevent_items
  end

  def update
    @preevent_product = @fetcher.preevent_products.find(params[:id])
    if @preevent_product.update(permitted_params)
      update_preevent_items_counter(permitted_params[:preevent_item_ids])
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_preevent_products_url
    else
      @preevent_items_collection = @fetcher.preevent_items
      flash[:error] = @preevent_product.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @preevent_product = @fetcher.preevent_products.find(params[:id])
    @preevent_product.destroy!
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_preevent_products_url
  end

  private

  def update_preevent_items_counter(preevent_item_ids)
    @preevent_product.preevent_items_counter(preevent_item_ids.reject!(&:empty?))
  end

  def add_amount_to_preevent_items(preevent_product_items_attributes)
    preevent_product_items_attributes.each do |id, amount|
      ppi = PreeventProductItem.find_by(preevent_product_id: @preevent_product.id, preevent_item_id: id.to_i)
      ppi.update_attribute(:amount, amount.to_i) if amount.present?
    end
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "PreeventProduct".constantize.model_name,
      fetcher: @fetcher.preevent_products,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: []
    )
  end

  def permitted_params
    params.require(:preevent_product).permit(
      :event_id,
      :name,
      :online,
      :description,
      :price,
      :min_purchasable,
      :max_purchasable,
      :initial_amount,
      :step,
      preevent_product_items_attributes: [:preevent_item_id, :amount]
    )
  end
end