class Admins::Events::PacksController < Admins::Events::BaseController
  before_action :set_pack, except: [:index, :new, :create]

  def index
    @packs = current_event.packs.includes(:catalog_items, pack_catalog_items: :catalog_item).page(params[:page])
  end

  def new
    @pack = current_event.packs.new
    @catalog_items_collection = current_event.catalog_items.not_user_flags
  end

  def create
    @pack = current_event.packs.new(permitted_params)

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
      @pack.pack_catalog_items.each do |item|
        item.destroy if item.marked_for_destruction?
      end
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

  private

  def set_pack
    @pack = current_event.packs.find(params[:id])
  end

  def permitted_params
    params.require(:pack).permit(:id,
                                 :event_id,
                                 :name,
                                 :description,
                                 :initial_amount,
                                 :step,
                                 :max_purchasable,
                                 :min_purchasable,
                                 pack_catalog_items_attributes: [:id, :catalog_item_id, :amount, :_destroy])
  end
end
