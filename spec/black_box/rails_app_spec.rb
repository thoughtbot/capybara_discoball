require "jet_black"

RSpec.describe "Using Discoball in a Rails app" do
  let(:session) { JetBlack::Session.new(options: { clean_bundler_env: true } ) }

  it "works with a block" do
    create_rails_application
    setup_discoball
    setup_rspec_rails
    install_success_api

    setup_controller_action(<<~RUBY)
      render :plain => SuccessAPI.get
    RUBY

    setup_integration_spec(<<~RUBY)
      visit '/successes'
      expect(page).to have_content('success')
    RUBY

    setup_spec_supporter(<<-RUBY)
      require 'sinatra/base'
      require 'capybara_discoball'
      require 'success_api'

      class FakeSuccess < Sinatra::Base
        get('/') { 'success' }
      end

      Capybara::Discoball.spin(FakeSuccess) do |server|
        SuccessAPI.endpoint_url = server.url
      end
    RUBY

    command = run_integration_test
    expect(command.stdout).to match(/1 example, 0 failures/)
    expect(command.exit_status).to eq 0
  end

  it "works without a block" do
    create_rails_application
    setup_discoball
    setup_rspec_rails
    install_success_api

    setup_controller_action(<<~RUBY)
      render :plain => SuccessAPI.get
    RUBY

    setup_integration_spec(<<~RUBY)
      visit '/successes'
      expect(page).to have_content('success')
    RUBY

    setup_spec_supporter(<<-RUBY)
      require 'sinatra/base'
      require 'capybara_discoball'
      require 'success_api'

      class FakeSuccess < Sinatra::Base
        get('/') { 'success' }
      end

      SuccessAPI.endpoint_url = Capybara::Discoball.spin(FakeSuccess)
    RUBY

    command = run_integration_test
    expect(command.stdout).to match(/1 example, 0 failures/)
    expect(command.exit_status).to eq 0
  end

  private

  def create_rails_application
    rails_new_cmd = [
      "bundle exec rails new .",
      "--skip-bundle",
      "--skip-test-unit",
      "--skip-coffee",
      "--skip-turbolinks",
    ].join(" ")

    # Use Rails from our own bundle
    command = session.run(rails_new_cmd, options: { clean_bundler_env: false })
    expect(command.stdout).to include "create  Gemfile"
  end

  def setup_discoball
    discoball_path = File.expand_path("../../", __dir__)

    session.append_to_file "Gemfile", <<~RUBY
      gem "capybara_discoball", :path => "#{discoball_path}"
      gem "sinatra"
    RUBY

    command = session.run("bundle install")
    expect(command.stdout).
      to match(/Using capybara_discoball .* from source at/)
  end

  def setup_rspec_rails
    session.append_to_file("Gemfile", <<~RUBY)
      gem "rspec-rails"
    RUBY

    session.run("bundle install")
    command = session.run("bundle exec rails g rspec:install")
    expect(command.stdout).to include "create  spec/rails_helper.rb"
  end

  def install_success_api
    session.create_file("app/models/success_api.rb", <<~RUBY)
      require 'net/http'
      require 'uri'

      class SuccessAPI
        @@endpoint_url = 'http://yahoo.com/'

        def self.endpoint_url=(endpoint_url)
          @@endpoint_url = endpoint_url
        end

        def self.get
          Net::HTTP.get(uri)
        end

        private

        def self.uri
          URI.parse(@@endpoint_url)
        end
      end
    RUBY
  end

  def setup_controller_action(content)
    session.create_file("app/controllers/whatever_controller.rb", <<~RUBY)
      class WhateverController < ApplicationController
        def the_action
          #{content}
        end
      end
    RUBY

    session.create_file("config/routes.rb", <<~RUBY)
      Rails.application.routes.draw do
        get '/successes', :to => 'whatever#the_action'
      end
    RUBY
  end

  def setup_integration_spec(spec_content)
    session.create_file("spec/integration/whatever_spec.rb", <<~RUBY)
      require 'rails_helper'
      require 'capybara/rspec'
      require 'support/whatever'

      RSpec.describe "whatever", :type => :feature do
        it "does the thing" do
          #{spec_content}
        end
      end
    RUBY
  end

  def setup_spec_supporter(support_content)
    session.create_file("spec/support/whatever.rb", support_content)
  end

  def run_integration_test
    session.run("bundle exec rspec spec/integration")
  end
end
