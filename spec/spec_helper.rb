RSpec.configure do |config|
  puts '+++++ Hey, I am at the beginning of spec_helper'

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  puts '+++++ Hey, I am at the end of spec_helper'
end
