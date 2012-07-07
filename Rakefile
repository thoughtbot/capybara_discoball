require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

namespace :spec do
  RSpec::Core::RakeTask.new(:acceptance) do |t|
    t.pattern = 'spec/acceptance/**/{*_spec.rb,*.feature}'
  end
end

task :spec => 'spec:acceptance'

task :default => [:spec]
