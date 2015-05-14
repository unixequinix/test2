class Admins::GtagsController < Admins::BaseController

  def index
    @q = Gtag.search(params[:q])
    @gtags = @q.result(distinct: true)
    respond_to do |format|
      format.html
      format.csv { send_data @gtags.to_csv }
    end
  end

  def search
    @q = Gtag.search(params[:q])
    @gtags = @q.result(distinct: true)
    render :index
  end

  def new
    @gtag = Gtag.new
  end

  def create
    @gtag = Gtag.new(permitted_params)
    if @gtag.save
      flash[:notice] = "created TODO"
      redirect_to admins_gtags_url
    else
      flash[:error] = "ERROR TODO"
      render :new
    end
  end

  def edit
    @gtag = Gtag.find(params[:id])
  end

  def update
    @gtag = Gtag.find(params[:id])
    if @gtag.update(permitted_params)
      flash[:notice] = "updated TODO"
      redirect_to admins_gtags_url
    else
      flash[:error] = "ERROR"
      render :edit
    end
  end

  def destroy
    @gtag = Gtag.find(params[:id])
    @gtag.destroy!
    flash[:notice] = "destroyed TODO"
    redirect_to admins_gtags_url
  end

  def import
    Gtag.import(params[:file])
    redirect_to admins_gtags_url, notice: "Gtags imported TODO"
  end

  private

  def permitted_params
    params.require(:gtag).permit(:tag_uid, :tag_serial_number)
  end

end
