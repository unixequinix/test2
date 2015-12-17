$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "core"
  s.version     = Core::VERSION
  s.authors     = ["Quino"]
  s.email       = ["quino@acidtango.com"]
  # s.homepage    = "TODO"
  s.summary     = "Summary of Checkin."
  s.description = "Description of Checkin."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]
end
