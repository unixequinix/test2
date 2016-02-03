$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "company_api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "company_api"
  s.version     = CompanyApi::VERSION
  s.authors     = ["Rubén"]
  s.email       = ["ruben@glownet.com"]
  # s.homepage    = "TODO"
  s.summary     = "Thirdparty API."
  s.description = "API for ticket companies."
  s.license     = "MIT"

  s.files = Dir["{app,config,lib}/**/*", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
end
