require "jet_black"

RSpec.describe "Using Discoball in a Rails app" do
  let(:session) do
    JetBlack::Session.new(options: { clean_bundler_env: true })
  end

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

    expect(run_integration_test).
      to be_a_success.and have_stdout(/1 example, 0 failures/)
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

    expect(run_integration_test).
      to be_a_success.and have_stdout("1 example, 0 failures")
  end

  private

  def create_rails_application
    session.create_file("Gemfile", <<~RUBY)
      source "http://rubygems.org"

      gem "rails"
    RUBY

    session.run("bundle install")

    rails_new_cmd = [
      "bundle exec rails new .",
      "--skip-bundle",
      "--skip-test",
      "--skip-coffee",
      "--skip-turbolinks",
      "--skip-spring",
      "--skip-bootsnap",
      "--force",
    ].join(" ")

    expect(session.run(rails_new_cmd)).
      to be_a_success.and have_stdout("force  Gemfile")
  end

  def setup_discoball
    discoball_path = File.expand_path("../../", __dir__)

    session.append_to_file "Gemfile", <<~RUBY
      gem "capybara_discoball", :path => "#{discoball_path}"
      gem "sinatra"
    RUBY

    expect(session.run("bundle install")).
      to be_a_success.and have_stdout(/capybara_discoball .* from source at/)
  end

  def setup_rspec_rails
    session.append_to_file("Gemfile", <<~RUBY)
      gem "rspec-rails"
    RUBY

    session.run("bundle install")

    expect(session.run("bundle exec rails g rspec:install")).
      to be_a_success.and have_stdout("create  spec/rails_helper.rb")
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
