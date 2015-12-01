class AccountManager::Stripe

  def platform_secret_key
    Rails.application.secrets.stripe_platform_secret
  end

  def persist_parameters(params, request)
    Stripe.api_key = platform_secret_key
    @account = build_account(params)
    account_parameters = extract_account_parameters
    attach_legal_parameters(params, request)
    legal_parameters = extract_legal_parameters

    persist!(account_parameters, params[:event_id])
    persist!(legal_parameters, params[:event_id])
  end

  private
  def build_account(params)
    parameters = params[:stripe_payment_settings_form]
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
    {
      legal_first_name: @account.legal_entity.first_name,
      legal_last_name: @account.legal_entity.last_name,
      legal_dob: "#{@account.legal_entity.dob.day}/#{@account.legal_entity.dob.month}/#{@account.legal_entity.dob.year}",
      legal_type: @account.legal_entity.type,
      tos_acceptance_date: @account.tos_acceptance.date,
      tos_acceptance_ip: @account.tos_acceptance.ip
    }
  end

  def attach_legal_parameters(params, request)
    parameters = params[:stripe_payment_settings_form]

    @account.legal_entity.first_name = parameters[:legal_first_name]
    @account.legal_entity.last_name = parameters[:legal_last_name]
    @account.legal_entity.dob.day = Date.parse(parameters[:legal_dob]).day
    @account.legal_entity.dob.month = Date.parse(parameters[:legal_dob]).month
    @account.legal_entity.dob.year = Date.parse(parameters[:legal_dob]).year
    @account.legal_entity.type = parameters[:legal_type]
    @account.tos_acceptance.ip = request.remote_ip
    @account.tos_acceptance.date = Time.now.to_i
    @account.save
  end


  def persist!(new_params, event_id)
    Parameter.where(category: 'payment', group: 'stripe', name: new_params.keys).each do |parameter|
      if !new_params[parameter.name.to_sym].nil?
        ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
        ep.nil? ?
        EventParameter.create!(value: new_params[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) :
        ep.update(value: new_params[parameter.name.to_sym])
      end
    end
  end

end