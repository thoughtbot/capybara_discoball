require "bundler/gem_tasks"

desc "Appraisals: Test different dependency versions"
task :run_appraisals do
  sh("bundle exec appraisal install")
  sh("bundle exec appraisal rspec --tag ~type:black_box")
end

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec)
  task default: [:spec, :run_appraisals]
rescue LoadError
end
