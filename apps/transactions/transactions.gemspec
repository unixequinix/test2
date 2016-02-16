$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transactions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transactions"
  s.version     = Transactions::VERSION
  s.authors     = ["Jake"]
  s.email       = ["jake@glownet.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Transactions."
  s.description = "TODO: Description of Transactions."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
end
