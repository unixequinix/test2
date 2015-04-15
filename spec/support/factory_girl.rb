RSpec.configure do |config|
  # shortcuts for factory_girl to use: create / build / build_stubbed
  config.include FactoryGirl::Syntax::Methods

  # FactoryGirl.lint builds each factory and subsequently calls #valid? on it (if #valid? is defined); if any calls to #valid? return false, FactoryGirl::InvalidFactoryError is raised with a list of the offending factories.
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end