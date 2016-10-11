class Admins::Events::ProfilesController < Admins::Events::BaseController
  before_action :set_profile, only: [:show, :ban, :unban, :download_transactions, :revoke_agreement]
  def index
    respond_to do |format|
      format.html { set_presenter }
      format.csv { send_data(Csv::CsvExporter.to_csv(Profile.query_for_csv(current_event))) }
    end
  end

  def search
    index
    render :index
  end

  def show
    # TODO: Its a workaround for sorting, remove after picnik is fixed
    @transactions = @profile.transactions(params[:sort])
  end

  def ban
    atts = fields(@profile.id, "Profile", "ban")

    @profile.update(banned: true)
    Transactions::Base.new.portal_write(atts)

    @profile.credential_assignments.each do |cred|
      obj = cred.credentiable
      atts = fields(obj.id, obj.class.name, "ban", "Profile was banned.")
      cred.credentiable.update(banned: true)
      Transactions::Base.new.portal_write(atts)
    end

    redirect_to(admins_event_profiles_url)
  end

  def unban
    atts = fields(@profile.id, "Profile", "unban")

    @profile.update(banned: false)
    Transactions::Base.new.portal_write(atts)
    redirect_to(admins_event_profiles_url)
  end

  def revoke_agreement
    @profile.payment_gateway_customers.find(params[:agreement_id]).destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to(admins_event_profile_path(current_event, @profile))
  end

  def fix_transaction
    credit_t = CreditTransaction.find(params[:transaction])
    money_t = MoneyTransaction.find_by(device_created_at: credit_t.device_created_at, profile_id: params[:id])
    fix_atts = { status_code: 0, status_message: "FIXED" }
    credit_t.update!(fix_atts)
    money_t.update(fix_atts) if money_t

    redirect_to(admins_event_profile_path(current_event, params[:id]))
  end

  def download_transactions
    @pdf_transactions = CreditTransaction.status_ok
                                         .not_record_credit
                                         .where(event: current_event, profile: @profile)
                                         .order("device_created_at asc")
    if @pdf_transactions.present?
      html = render_to_string(action: :transactions_pdf, layout: false)
      pdf = WickedPdf.new.pdf_from_string(html)
      send_data(pdf, filename: "transaction_history_#{@profile.id}.pdf", disposition: "attachment")
    else
      flash[:error] = I18n.t("alerts.profile_without_transactions")
      redirect_to(admins_event_profile_path(current_event, @profile))
    end
  end

  def set_presenter
    @list_model_presenter = ListModelPresenter.new(
      model_name: "Profile".constantize.model_name,
      fetcher: current_event.profiles,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [
        :customer,
        credential_assignments: :credentiable,
        active_tickets_assignment: :credentiable,
        active_gtag_assignment: :credentiable
      ]
    )
  end

  private

  def set_profile
    @profile = current_event.profiles.find(params[:id])
  end

  def fields(b_id, b_type, t_type, reason = "Banned by #{current_admin.email}")
    {
      event_id: current_event.id,
      transaction_category: "ban",
      transaction_type: "#{t_type}_#{b_type.downcase}",
      banneable_id: b_id,
      banneable_type: b_type,
      reason: reason
    }
  end
end
