class AccountManager::Stripe

  def platform_secret_key
    Rails.application.secrets.stripe_platform_secret
  end

  def persist_parameters(params, _request)
    Stripe.api_key = platform_secret_key
    @account = build_account(params)
    account_parameters = extract_account_parameters
    persist!(account_parameters, params[:event_id])
  end

  def upload_document(document, stripe_account, secret_key)
    Stripe.api_key = secret_key
    file = {:purpose => 'identity_document', :file => File.new(document.path) }
    Stripe::FileUpload.create(file, {:stripe_account => stripe_account})[:id]
  end

  def update_parameters(params, request)
    Stripe.api_key = params[:account_secret_key]

    @account = Stripe::Account.retrieve(params[:stripe_account_id])
    if @account.external_accounts.empty?
      @account.external_accounts.create(external_account: {object: "bank_account", account_number: params[:bank_account], country: params[:country], currency: params[:currency]})
    end
    @account.legal_entity.verification.document = params[:document] if params[:document]
    @account.legal_entity.first_name = params[:legal_first_name]
    @account.legal_entity.last_name = params[:legal_last_name]
    @account.legal_entity.dob.day = params[:legal_dob].to_date.day
    @account.legal_entity.dob.month = params[:legal_dob].to_date.month
    @account.legal_entity.dob.year = params[:legal_dob].to_date.year
    @account.legal_entity.type = params[:legal_type]
    @account.legal_entity.address.city = params[:city]
    @account.legal_entity.address.line1 = params[:line1]
    @account.legal_entity.address.postal_code = params[:postal_code]
    @account.legal_entity.additional_owners = [{
      first_name: params[:additional_owner_first_name],
      last_name: params[:additional_owner_last_name],
      dob: {
        day: params[:additional_owner_dob].to_date.day,
        month: params[:additional_owner_dob].to_date.month,
        year: params[:additional_owner_dob].to_date.year
      },
      address: {
        city: params[:additional_owner_address_city],
        line1: params[:additional_owner_address_line1],
        postal_code: params[:additional_owner_address_postal_code]
      }
    }]
    @account.legal_entity.additional_owners[0][:verification] = { document: params[:additional_owner_document] } if params[:additional_owner_document]
    @account.legal_entity.business_name = params[:business_name]
    @account.legal_entity.business_tax_id = params[:business_tax_id]
    @account.legal_entity.personal_address.city = params[:city]
    @account.legal_entity.personal_address.line1 = params[:line1]
    @account.legal_entity.personal_address.postal_code = params[:postal_code]
    @account.tos_acceptance = @account.tos_acceptance
    @account.tos_acceptance.ip = request.remote_ip
    @account.tos_acceptance.date = Time.zone.now.to_i

    @account.save
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

  def persist!(new_params, event_id)
    Parameter.where(category: "payment", group: "stripe", name: new_params.keys).each do |parameter|
      next if new_params[parameter.name.to_sym].nil?
      ep = EventParameter.find_or_create_by(event_id: event_id, parameter_id: parameter.id)
      ep.value = new_params[parameter.name.to_sym]
      ep.save!
    end
  end
end
