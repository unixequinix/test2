class Admins::Events::ProfilesController < Admins::Events::BaseController
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
    @profile = @fetcher.profiles.with_deleted.find(params[:id])
  end

  def ban
    profile = @fetcher.profiles.find(params[:id])
    atts = fields(profile.id, "Profile", "ban")

    profile.update(banned: true)
    Operations::Base.new.portal_write(atts)

    profile.credential_assignments.each do |cred|
      obj = cred.credentiable
      atts = fields(obj.id, obj.class.name, "ban", "Profile was banned.")
      cred.credentiable.update(banned: true)
      Operations::Base.new.portal_write(atts)
    end

    redirect_to(admins_event_profiles_url)
  end

  def unban
    profile = @fetcher.profiles.find(params[:id])
    atts = fields(profile.id, "Profile", "unban")

    profile.update(banned: false)
    Operations::Base.new.portal_write(atts)
    redirect_to(admins_event_profiles_url)
  end

  def revoke_agreement
    profile = @fetcher.profiles.find(params[:id])
    profile.payment_gateway_customers.find(params[:agreement_id]).destroy
    flash[:notice] = I18n.t("alerts.destroyed")
    redirect_to(admins_event_profile_path(current_event, profile))
  end

  def fix_transaction
    credit_t = CreditTransaction.find(params[:transaction])
    money_t = MoneyTransaction.find_by(device_created_at: credit_t.device_created_at, profile_id: params[:id])
    fix_atts = { status_code: 0, status_message: "FIXED" }
    credit_t.update!(fix_atts)
    money_t.update(fix_atts)

    redirect_to(admins_event_profile_path(current_event, params[:id]))
  end

  def download_transactions
    @profile = @fetcher.profiles.find(params[:id])
    @pdf_transactions = CreditTransaction.where(status_code: 0, profile: @profile).order("device_created_at asc")
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
      fetcher: @fetcher.profiles,
      search_query: params[:q],
      page: params[:page],
      context: view_context,
      include_for_all_items: [
        :customer,
        :active_tickets_assignment,
        :active_gtag_assignment,
        credential_assignments: :credentiable
      ]
    )
  end

  private

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
