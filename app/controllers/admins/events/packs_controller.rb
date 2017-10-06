class Admins::Events::PacksController < Admins::Events::BaseController
  before_action :set_pack, except: %i[index new create]
  before_action :set_catalog_items, except: %i[index destroy]

  def index
    @packs = @current_event.packs.includes(:catalog_items)
    authorize @packs
    @packs = @packs.page(params[:page])
  end

  def new
    @pack = @current_event.packs.new
    @item = @current_event.user_flags.find_by(name: "alcohol_forbidden")
    @pack.pack_catalog_items.build(catalog_item: @item)
    authorize @pack
  end

  def edit
    @item = @current_event.user_flags.find_by(name: "alcohol_forbidden")
    @pack.pack_catalog_items.build(catalog_item: @item)
    authorize @pack
  end

  def create
    flag = permitted_params.delete(:alcohol_forbidden)
    @item = @current_event.user_flags.find_by(name: "alcohol_forbidden")

    @pack = @current_event.packs.new(permitted_params)
    authorize @pack

    if @pack.save
      @pack.pack_catalog_items.create(catalog_item: @item, amount: flag) if flag.eql?("1")
      redirect_to [:admins, @current_event, @pack], notice: t("alerts.created")
    else
      @pack.pack_catalog_items.build(catalog_item: @item, amount: flag)
      flash.now[:alert] = t("alerts.error")
      render :new
    end
  end

  def update
    flag = permitted_params.delete(:alcohol_forbidden)
    @item = @current_event.user_flags.find_by(name: "alcohol_forbidden")

    if @pack.update(permitted_params)
      @pack.pack_catalog_items.find_or_create_by(catalog_item: @item, amount: flag) if flag.eql?("1")
      @pack.pack_catalog_items.find_by(catalog_item: @item)&.destroy if flag.to_i.eql?("0")

      # TODO: find out why the fuck are these lines necessary when rails supposedly does this by itself. (jake)
      @pack.pack_catalog_items.map(&:save)
      @pack.pack_catalog_items.select(&:marked_for_destruction?).map(&:destroy)

      redirect_to [:admins, @current_event, @pack], notice: t("alerts.updated")
    else
      flash.now[:alert] = t("alerts.error")
      render :edit
    end
  end

  def destroy
    respond_to do |format|
      if @pack.destroy
        format.html { redirect_to admins_event_packs_path, notice: t("alerts.destroyed") }
        format.json { render json: true }
      else
        format.html { redirect_to [:admins, @current_event, @pack], alert: @pack.errors.full_messages.to_sentence }
        format.json { render json: { errors: @pack.errors }, status: :unprocessable_entity }
      end
    end
  end

  def clone
    @pack = @pack.deep_clone(include: :pack_catalog_items, validate: false)
    @pack.update!(name: "#{@pack.name} - #{@current_event.packs.count}")
    redirect_to [:edit, :admins, @current_event, @pack], notice: t("alerts.created")
  end

  private

  def set_pack
    @pack = @current_event.packs.find(params[:id])
    @item = @current_event.user_flags.find_by(name: "alcohol_forbidden")
    authorize @pack
  end

  def set_catalog_items
    @catalog_items_collection = @current_event.catalog_items.not_user_flags.not_packs.group_by { |item| item.type.underscore.humanize.pluralize }
  end

  def permitted_params
    params.require(:pack).permit(:name, :alcohol_forbidden, pack_catalog_items_attributes: %i[id catalog_item_id amount _destroy])
  end
end
