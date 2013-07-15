$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "eve_data/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "mram-eve_data"
  s.version     = EveData::VERSION
  s.authors     = ["Markus Rambossek"]
  s.email       = ["git@rambossek.at"]
  s.homepage    = "https://github.com/mrambossek/mram-evedata"
  s.summary     = %q{EVE Online Static Data Dump Rails Integration}
  s.description = %q{This mountable Rails Engine will import the EVE Online Static Data Dump and provide a framework for accessing it}

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 3.2"
  s.add_dependency "ruby-progressbar"
  s.add_dependency "ancestry", ">= 2.0.0"

  s.add_runtime_dependency 'mysql2'
end
