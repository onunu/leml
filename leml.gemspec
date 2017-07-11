$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "leml/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "leml"
  s.version     = Leml::VERSION
  s.authors     = ["onunu"]
  s.email       = ["riku.onuma@livesense.co.jp", "onunu@zeals.co.jp"]
  s.homepage    = "https://github.com/onunu/leml"
  s.summary     = "Encrypt only leaf of your secrets yaml file"
  s.description = "Merge your yaml to rails secrets, and it encrypted only leaf"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.2.9"

  s.add_development_dependency "sqlite3"
end
