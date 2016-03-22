$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api"
  s.version     = Api::VERSION
  s.authors     = ["Rubén"]
  s.email       = ["ruben@glownet.com"]
  s.homepage    = "http://www.glownet.com"
  s.summary     = "Summary of Api."
  s.description = "Description of Api."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2.1"
end
