require 'rspec'
require 'turnip'
require 'aruba/api'
Dir["spec/{support,step_definitions}/**/*.rb"].each { |f| require File.expand_path(f) }

RSpec.configure do |config|
  config.include Aruba::Api
  config.include RailsSupport

  config.before(:all) do
    @aruba_timeout_seconds = 140
    if ENV['DEBUG']
      @puts = true
      @announce_stdout = true
      @announce_stderr = true
      @announce_cmd = true
      @announce_dir = true
      @announce_env = true
    end
  end
end
