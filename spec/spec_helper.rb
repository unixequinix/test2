RSpec.configure do |config|

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

def event_to_hash_parameters(event) # method for testing
  { name: event.name,
    aasm_state: event.aasm_state,
    slug: event.slug,
    location: event.location,
    start_date: event.start_date,
    end_date: event.end_date,
    description: event.description,
    support_email: event.support_email,
    style: event.style,
    logo_file_name: event.logo_file_name,
    logo_content_type: event.logo_content_type,
    logo_file_size: event.logo_file_size,
    logo_updated_at: event.logo_updated_at,
    background_file_name: event.background_file_name,
    background_content_type: event.background_content_type,
    background_file_size: event.background_file_size,
    background_updated_at: event.background_updated_at,
    url: event.url,
    background_type: event.background_type,
    features: event.features,
    refund_services: event.refund_services,
    gtag_registration: event.gtag_registration,
    payment_service: event.payment_service,
    host_country: event.host_country,
    currency: event.currency,
    locales: event.locales,
    registration_parameters: event.registration_parameters }
end
