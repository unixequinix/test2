class Admins::Events::VouchersController < Admins::Events::BaseController
  before_action :set_voucher, only: [:show, :edit, :update, :destroy, :create_credential, :destroy_credential]

  def index
    set_presenter
  end

  def new
    @voucher = Voucher.new
    @products_collection = current_event.products
    @voucher.build_catalog_item
    @voucher.build_entitlement
  end

  def create
    @voucher = Voucher.new(permitted_params)
    if @voucher.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_vouchers_url
    else
      @products_collection = current_event.products
      flash.now[:error] = @voucher.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @products_collection = current_event.products
  end

  def update
    if @voucher.update_attributes(permitted_params)
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_vouchers_url
    else
      @products_collection = current_event.products
      flash.now[:error] = @voucher.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    if @voucher.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
      redirect_to admins_event_vouchers_url
    else
      flash.now[:error] = I18n.t("errors.messages.catalog_item_dependent")
      set_presenter
      render :index
    end
  end

  def create_credential
    @voucher.catalog_item.create_credential_type if @voucher.catalog_item.credential_type.blank?
    redirect_to admins_event_vouchers_url
  end

  def destroy_credential
    @voucher.catalog_item.credential_type.destroy if @voucher.catalog_item.credential_type.present?
    redirect_to admins_event_vouchers_url
  end

  private

  def set_voucher
    @voucher = current_event.vouchers.find(params[:id])
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Voucher".constantize.model_name,
      fetcher: current_event.vouchers,
      search_query: params[:q],
      page: params[:page],
      include_for_all_items: [:entitlement, catalog_item: :credential_type],
      context: view_context
    )
  end

  def permitted_params
    params.require(:voucher).permit(product_ids: [],
                                    catalog_item_attributes: [:id,
                                                              :event_id,
                                                              :name,
                                                              :description,
                                                              :initial_amount,
                                                              :step,
                                                              :max_purchasable,
                                                              :min_purchasable],
                                    entitlement_attributes: [:id,
                                                             :memory_length,
                                                             :mode,
                                                             :event_id])
  end
end
