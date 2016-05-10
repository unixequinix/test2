class AccountManager::Stripe
  def platform_secret_key
    Rails.application.secrets.stripe_platform_secret
  end

  def persist_parameters(params, _request)
    Stripe.api_key = platform_secret_key
    @account = build_account(params)
    account_parameters = extract_account_parameters
    # TODO: next lines are to manage legal parameters
    # attach_legal_parameters(params, request)
    # legal_parameters = extract_legal_parameters
    persist!(account_parameters, params[:event_id])
    # persist!(legal_parameters, params[:event_id])
  end

  private

  # TODO: Remove dependancy of the view
  def build_account(params)
    parameters = params[:stripe_payment_activation_form]
    acc_params = {
      managed: true,
      email: parameters[:email],
      country: parameters[:country],
      default_currency: parameters[:currency],
      bank_account: parameters[:bankAccountToken]
    }
    Stripe::Account.create(acc_params)
  end

  def extract_account_parameters
    {
      email: @account.email,
      country: @account.country,
      currency: @account.default_currency,
      bank_account: @account.external_accounts.first && @account.external_accounts.first.id,
      stripe_account_id: @account.id,
      account_secret_key: @account.keys.secret,
      account_publishable_key: @account.keys.publishable
    }
  end

  def extract_legal_parameters
    entity = @account.legal_entity
    tos = @account.tos_acceptance
    {
      legal_first_name: entity.first_name,
      legal_last_name: entity.last_name,
      legal_dob: "#{entity.dob.day}/#{entity.dob.month}/#{entity.dob.year}",
      legal_type: entity.type,
      tos_acceptance_date: tos.date,
      tos_acceptance_ip: tos.ip
    }
  end

  def attach_legal_parameters(params, request)
    legal_entity(@account.legal_entity, params[:stripe_payment_settings_form])
    tos = @account.tos_acceptance
    tos.ip = request.remote_ip
    tos.date = Time.zone.now.to_i
    @account.save
  end

  def legal_entity(entity, params)
    entity.first_name = params[:legal_first_name]
    entity.last_name = params[:legal_last_name]
    entity.dob.day = Date.parse(params[:legal_dob]).day
    entity.dob.month = Date.parse(params[:legal_dob]).month
    entity.dob.year = Date.parse(params[:legal_dob]).year
    entity.type = params[:legal_type]
  end

  def persist!(new_params, event_id)
    Parameter.where(category: "payment", group: "stripe", name: new_params.keys).each do |parameter|
      next if new_params[parameter.name.to_sym].nil?
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.value = new_params[parameter.name.to_sym]
      ep.save!
    end
  end
end
