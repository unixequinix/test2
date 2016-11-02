class Admins::Events::PacksController < Admins::Events::BaseController
  before_action :set_pack, except: [:index, :new, :create]

  def index
    @packs = current_event.packs
                          .includes(:catalog_items_included,
                                    catalog_item: :credential_type,
                                    pack_catalog_items: { catalog_item: :catalogable })
                          .page(params[:page])
  end

  def new
    @pack = Pack.new
    @pack.build_catalog_item
    @catalog_items_collection = current_event.catalog_items
  end

  def create
    @pack = Pack.new(permitted_params)
    if @pack.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_packs_url
    else
      @catalog_items_collection = current_event.catalog_items
      flash.now[:error] = @pack.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @catalog_items_collection = current_event.catalog_items
  end

  def update
    @pack.assign_attributes(permitted_params)
    if @pack.save
      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_packs_url
    else
      @catalog_items_collection = current_event.catalog_items
      flash.now[:error] = @pack.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    if @pack.destroy
      flash[:notice] = I18n.t("alerts.destroyed")
    else
      flash[:error] = I18n.t("errors.messages.station_dependent")
    end
    redirect_to admins_event_packs_url
  end

  def create_credential
    @pack.catalog_item.create_credential_type if @pack.catalog_item.credential_type.blank?
    redirect_to admins_event_packs_url
  end

  def destroy_credential
    @pack.catalog_item.credential_type.destroy if @pack.catalog_item.credential_type.present?
    redirect_to admins_event_packs_url
  end

  private

  def set_pack
    @pack = current_event.packs.find(params[:id])
  end

  def permitted_params
    params.require(:pack).permit(catalog_item_attributes: [:id,
                                                           :event_id,
                                                           :name,
                                                           :description,
                                                           :initial_amount,
                                                           :step,
                                                           :max_purchasable,
                                                           :min_purchasable],
                                 pack_catalog_items_attributes: [:id,
                                                                 :catalog_item_id,
                                                                 :amount,
                                                                 :_destroy])
  end
end
