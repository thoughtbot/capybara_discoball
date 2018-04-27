# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "capybara_discoball/version"

Gem::Specification.new do |s|
  s.name        = "capybara_discoball"
  s.version     = Capybara::Discoball::VERSION
  s.authors     = ["Mike Burns"]
  s.email       = ["mburns@thoughtbot.com"]
  s.homepage    = ""
  s.summary     = %q{Spin up an external server just for Capybara}
  s.description = <<-DESC
When ShamRack doesn't quite cut it; when your JavaScript and non-Ruby
code needs to hit an external API for your tests; when you're excited
about spinning up a full server instead of faking out Net::HTTP: we
present the Discoball.
  DESC

  s.rubyforge_project = "capybara_discoball"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'capybara', '~> 2.7'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'rails'
  s.add_development_dependency 'jet_black', '~> 0.2'
  s.add_development_dependency 'pry'
end
