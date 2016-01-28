$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "transactions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "transactions"
  s.version     = Logging::VERSION
  s.authors     = ["Jake"]
  s.email       = ["jake@glownet.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Logging."
  s.description = "TODO: Description of Logging."
  s.license     = "MIT"
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]
  s.add_dependency "rails", "~> 4.2.1"
end
