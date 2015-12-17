$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "administration/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "administration"
  s.version     = Administration::VERSION
  s.authors     = ["Quino"]
  s.email       = ["quino@acidtango.com"]
  # s.homepage    = "TODO"
  s.summary     = "Summary of Administration."
  s.description = "Description of Administration."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.1"
end
