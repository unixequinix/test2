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

    tag = @profile.active_gtag_assignment&.credentiable&.tag_uid
    @credit_transactions = CreditTransaction.where(event: current_event, customer_tag_uid: tag)
                                            .order(device_created_at: :desc)
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
      station_id: current_event.stations
                               .joins(:station_type)
                               .find_by(station_types: { name: "customer_portal" }).id,
      transaction_category: "ban",
      transaction_origin: "customer_portal",
      transaction_type: "#{t_type}_#{b_type.downcase}",
      banneable_id: b_id,
      banneable_type: b_type,
      reason: reason,
      status_code: 0,
      status_message: "OK"
    }
  end
end
