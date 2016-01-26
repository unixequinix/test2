class Admins::Events::VouchersController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def new
    @voucher = Voucher.new
    @voucher.build_preevent_item
  end

  def create
    @voucher = Voucher.new(permitted_params)
    if @voucher.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_vouchers_url
    else
      flash[:error] = @voucher.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @voucher = @fetcher.vouchers.find(params[:id])
  end

  def update
    @voucher = @fetcher.vouchers.find(params[:id])
    if @voucher.update(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_vouchers_url
    else
      flash[:error] = @voucher.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @voucher = @fetcher.vouchers.find(params[:id])
    update_preevent_products
    @voucher.destroy!
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to admins_event_vouchers_url
  end

  private

  def update_preevent_products
    @voucher.preevent_item.preevent_products.each do |pp|
      pp.preevent_items_counter_decrement
      binding.pry
      pp.destroy if pp.preevent_items_count <= 0
    end
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Voucher".constantize.model_name,
      fetcher: @fetcher.vouchers,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:preevent_item],
      context: view_context
    )
  end

  def permitted_params
    params.require(:voucher).permit(:counter,
                                    preevent_item_attributes: [
                                      :event_id,
                                      :name,
                                      :description
                                    ]
                                   )
  end
end
