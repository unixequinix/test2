class AccountGenerator::Stripe

  def self.platform_secret_key
    Rails.application.secrets.stripe_platform_secret
  end

  def self.generate_params(params)
    Stripe.api_key = platform_secret_key
    account_parameters = extracted_account_values(params)
    binding.pry
    account = build_account(account_parameters)
    stripe_parameters = data_to_store(account)
    persist!(stripe_parameters, params[:event_id])
  end

  # Private Class methods
  def self.data_to_store(account)
    {
      stripe_account_id: account.id,
      account_secret_key: account.keys.secret,
      account_publishable_key: account.keys.publishable
    }
  end

  def self.extracted_account_values(params)
    binding.pry
    parameters = params[:stripe_payment_settings_form]
    {
      managed: true,
      email: parameters[:email],
      country: parameters[:country],
      default_currency: parameters[:currency],
      bank_account: params[:bankAccountToken]
    }
  end

  def self.build_account(account_parameters)
    binding.pry
    new_account = Stripe::Account.create(account_parameters)
  end

  def self.persist!(new_params, event_id)
    Parameter.where(category: 'payment', group: 'stripe', name: new_params.keys).each do |parameter|
      ep = EventParameter.find_by(event_id: event_id, parameter_id: parameter.id)
      ep.nil? ?
      EventParameter.create!(value: new_params[parameter.name.to_sym], event_id: event_id, parameter_id: parameter.id) :
      ep.update(value: new_params[parameter.name.to_sym])
    end
  end

  private_class_method :extracted_account_values
  private_class_method :data_to_store
  private_class_method :build_account
  private_class_method :persist!

end