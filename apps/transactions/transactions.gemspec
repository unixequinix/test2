$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transactions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transactions"
  s.version     = Transactions::VERSION
  s.authors     = ["Jake"]
  s.email       = ["jake@glownet.com"]
  s.homepage    = "http://www.glownet.com"
  s.summary     = "Summary of Transactions."
  s.description = "Description of Transactions."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc", "spec/factories/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
end
