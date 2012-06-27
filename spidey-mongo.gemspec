# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "spidey-mongo/version"

Gem::Specification.new do |s|
  s.name        = "spidey-mongo"
  s.version     = Spidey::Mongo::VERSION
  s.authors     = ["Joey Aghion"]
  s.email       = ["joey@aghion.com"]
  s.homepage    = "https://github.com/joeyAghion/spidey-mongo"
  s.summary     = %q{Implements a MongoDB back-end for Spidey, a framework for crawling and scraping web sites.}
  s.description = %q{Implements a MongoDB back-end for Spidey, a framework for crawling and scraping web sites.}
  s.license     = 'MIT'

  s.rubyforge_project = "spidey-mongo"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
  
  s.add_runtime_dependency "spidey"
  s.add_runtime_dependency "mongo"
  s.add_runtime_dependency "bson_ext"
end
