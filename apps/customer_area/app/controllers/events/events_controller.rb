class Events::EventsController < Events::BaseController
  def show
    @dashboard = Dashboard.new(current_customer_event_profile, view_context)
    Braintree::Configuration.environment  = ENV['BRAINTREE_ENV']         || :sandbox
    Braintree::Configuration.merchant_id   = ENV['BRAINTREE_MERCHANT_ID'] || 'ggtbw7zbswh382kw'
    Braintree::Configuration.public_key   = ENV['BRAINTREE_PUBLIC_KEY']  || 'xgbtvr7dnsgddgpq'
    Braintree::Configuration.private_key  = ENV['BRAINTREE_PRIVATE_KEY'] || '2d008acc70e917328fd6161ffa92c021'
    @client_token = Braintree::ClientToken.generate
  end
end
