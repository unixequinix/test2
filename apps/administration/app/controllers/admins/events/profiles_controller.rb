class Admins::Events::ProfilesController < Admins::Events::BaseController
  def index
    set_presenter
  end

  def search
    index
    render :index
  end

  def show
    @profile = @fetcher.profiles.with_deleted
                       .includes(:active_tickets_assignment,
                                 :active_gtag_assignment,
                                 credential_assignments: :credentiable,
                                 customer_orders: [:catalog_item, :online_order])
                       .find(params[:id])

    tag_uid = @profile.active_gtag_assignment&.credentiable&.tag_uid
    @credit_transactions = CreditTransaction.with_event(current_event)
                                            .with_customer_tag(tag_uid)
                                            .reorder(gtag_counter: :desc)
                                            .includes(:station)
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
    transaction = CreditTransaction.find(params[:transaction])
    transaction.update!(status_code: 0, status_message: "FIXED")
    atts = {
      transaction_origin: transaction.transaction_origin,
      profile_id: params[:id],
      credits_refundable: transaction.credits_refundable,
      credits: transaction.credits,
      credit_value: transaction.credit_value,
      final_balance: transaction.final_balance,
      final_refundable_balance: transaction.final_refundable_balance,
      device_created_at: transaction.device_created_at,
      gtag_counter: transaction.gtag_counter
    }
    Operations::Credit::BalanceUpdater.new.perform(atts)

    redirect_to(admins_event_profile_path(current_event, params[:id]))
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
