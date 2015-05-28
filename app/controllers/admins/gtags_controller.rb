class Admins::GtagsController < Admins::BaseController

  def index
    @q = Gtag.search(params[:q])
    @gtags = @q.result(distinct: true).page(params[:page]).includes(:assigned_gtag_registration, :gtag_credit_log)
    respond_to do |format|
      format.html
      format.csv { send_data @gtags.to_csv }
    end
  end

  def search
    @q = Gtag.search(params[:q])
    @gtags = @q.result(distinct: true).page(params[:page]).includes(:assigned_gtag_registration, :gtag_credit_log)
    render :index
  end

  def new
    @gtag = Gtag.new
    @gtag.build_gtag_credit_log
  end

  def create
    @gtag = Gtag.new(permitted_params)
    if @gtag.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_gtags_url
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      render :new
    end
  end

  def edit
    @gtag = Gtag.find(params[:id])
    @gtag.build_gtag_credit_log unless @gtag.gtag_credit_log
  end

  def update
    @gtag = Gtag.find(params[:id])
    if @gtag.update(permitted_params)
      flash[:notice] = I18n.t('alerts.updated')
      redirect_to admins_gtags_url
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @gtag = Gtag.find(params[:id])
    if @gtag.destroy
      flash[:notice] = I18n.t('alerts.destroyed')
      redirect_to admins_gtags_url
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      redirect_to admins_gtags_url
    end
  end

  def import
    if Gtag.import(params[:file])
      flash[:notice] = I18n.t('alerts.imported')
      redirect_to admins_gtags_url
    else
      flash[:error] = I18n.t('alerts.error')
      redirect_to admins_gtags_url
    end
  end

  private

  def permitted_params
    params.require(:gtag).permit(:tag_uid, :tag_serial_number, gtag_credit_log_attributes: [:id, :amount, :_destroy])
  end

end
