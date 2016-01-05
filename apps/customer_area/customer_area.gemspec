$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "customer_area/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "customer_area"
  s.version     = CustomerArea::VERSION
  s.authors     = ["Quino"]
  s.email       = ["quino@acidtango.com"]
  # s.homepage    = "TODO"
  s.summary     = "Summary of Customer Area."
  s.description = "Description of Customer Area."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
end
