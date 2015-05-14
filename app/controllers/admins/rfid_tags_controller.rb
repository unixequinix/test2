class Admins::RfidTagsController < Admins::BaseController

  def index
    @q = RfidTag.search(params[:q])
    @rfid_tags = @q.result(distinct: true).includes(:rfid_tag_type, :assigned_admission)
    respond_to do |format|
      format.html
      format.csv { send_data @rfid_tags.to_csv }
    end
  end

  def search
    @q = RfidTag.search(params[:q])
    @rfid_tags = @q.result(distinct: true).includes(:rfid_tag_type, :assigned_admission)
    render :index
  end

  def new
    @rfid_tag = RfidTag.new
  end

  def create
    @rfid_tag = RfidTag.new(permitted_params)
    if @rfid_tag.save
      flash[:notice] = "created TODO"
      redirect_to admins_rfid_tags_url
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end

  def edit
    @rfid_tag = RfidTag.find(params[:id])
  end

  def update
    @rfid_tag = RfidTag.find(params[:id])
    if @rfid_tag.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admins_rfid_tags_url
    else
      flash[:error] = "ERROR"
      render :edit
    end
  end

  def destroy
    @rfid_tag = RfidTag.find(params[:id])
    @rfid_tag.destroy!
    flash[:notice] = "destroyed TODO"
    redirect_to admins_rfid_tags_url
  end

  def import
    RfidTag.import(params[:file])
    redirect_to admins_rfid_tags_url, notice: "RfidTags imported TODO"
  end

  private

  def permitted_params
    params.require(:rfid_tag).permit(:number, :rfid_tag_type_id)
  end

end
