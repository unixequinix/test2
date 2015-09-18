class Admins::Events::GtagsController < Admins::Events::BaseController

  def index
    @q = Gtag.where(event_id: current_event.id).search(params[:q])
    @gtags = @q.result(distinct: true).page(params[:page]).includes(:assigned_gtag_registration, :gtag_credit_log)
    respond_to do |format|
      format.html
      #format.csv { send_data Gtag.where(event_id: current_event.id).to_csv }
      format.csv { send_data Csv::CsvExporter.to_csv(Gtag.selected_data(current_event.id)) }

    end
  end

  def search
    @q = Gtag.where(event_id: current_event.id).search(params[:q])
    @gtags = @q.result(distinct: true).page(params[:page]).includes(:assigned_gtag_registration, :gtag_credit_log)
    render :index
  end

  def show
    @gtag = Gtag.includes(gtag_registrations: :customer_event_profile).find(params[:id])
  end

  def new
    @gtag = Gtag.new
    @gtag.build_gtag_credit_log
  end

  def create
    @gtag = Gtag.new(permitted_params)
    if @gtag.save
      flash[:notice] = I18n.t('alerts.created')
      redirect_to admins_event_gtags_url
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
      redirect_to admins_event_gtag_url(current_event, @gtag)
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      render :edit
    end
  end

  def destroy
    @gtag = Gtag.find(params[:id])
    if @gtag.destroy
      flash[:notice] = I18n.t('alerts.destroyed')
      redirect_to admins_event_gtags_url
    else
      flash[:error] = @gtag.errors.full_messages.join(". ")
      redirect_to admins_event_gtags_url
    end
  end

  def destroy_multiple
    if gtags = params[:gtags]
      Gtag.where(id: gtags.keys).each do |gtag|
        if !gtag.destroy
          flash[:error] = gtag.errors.full_messages.join(". ")
        end
      end
    end
    redirect_to admins_event_gtags_url
  end

  private

  def permitted_params
    params.require(:gtag).permit(:event_id, :tag_uid, :tag_serial_number, gtag_credit_log_attributes: [:id, :gtag_id, :amount, :_destroy])
  end

end
