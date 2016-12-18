class Admins::Events::PacksController < Admins::Events::BaseController
  before_action :set_pack, except: [:index, :new, :create]
  before_action :set_catalog_items, except: [:index, :destroy]

  def index
    @packs = @current_event.packs.includes(:catalog_items).page(params[:page])
  end

  def new
    @pack = @current_event.packs.new
  end

  def create
    @pack = @current_event.packs.new(permitted_params)

    if @pack.save
      flash[:notice] = I18n.t("alerts.created")
      redirect_to admins_event_packs_url
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :new
    end
  end

  def update
    if @pack.update(permitted_params)
      # TODO: find out why the fuck are these lines necessary when rails supposedly does this by itself.
      @pack.pack_catalog_items.map(&:save)
      @pack.pack_catalog_items.select(&:marked_for_destruction?).map(&:destroy)

      flash[:notice] = I18n.t("alerts.updated")
      redirect_to admins_event_packs_path
    else
      flash.now[:error] = I18n.t("alerts.error")
      render :edit
    end
  end

  def destroy
    @pack.destroy
    redirect_to admins_event_packs_path, notice: I18n.t("alerts.destroyed")
  end

  private

  def set_pack
    @pack = @current_event.packs.find(params[:id])
  end

  def set_catalog_items
    @catalog_items_collection = @current_event.catalog_items.not_user_flags.not_packs
  end

  def permitted_params
    params.require(:pack).permit(:name, :initial_amount, :step, :max_purchasable, :min_purchasable, pack_catalog_items_attributes: [:id, :catalog_item_id, :amount, :_destroy]) # rubocop:disable Metrics/LineLength
  end
end
