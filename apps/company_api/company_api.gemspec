$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "company_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "company_api"
  s.version     = CompanyApi::VERSION
  s.authors     = ["Rubén"]
  s.email       = ["ruben@glownet.com"]
  s.homepage    = "http://www.glownet.com"
  s.summary     = "Summary of Company Api."
  s.description = "Description of Company Api."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "README.rdoc", "spec/factories/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'factory_girl_rails'
end
