step %{I have a Rails application with Discoball installed} do
  create_rails_app
  append_to_file("Gemfile", <<-GEMS)
    gem 'rspec-rails'
  GEMS
  run_simple "bundle exec rails generate rspec:install"
end

step %{the following controller action:} do |action_content|
  write_file("app/controllers/whatever_controller.rb", <<-CONTROLLER)
    class WhateverController < ApplicationController
      def the_action
        #{action_content}
      end
    end
  CONTROLLER
  write_file("config/routes.rb", <<-ROUTES)
    Testapp::Application.routes.draw do
      get '/successes', :to => 'whatever#the_action'
    end
  ROUTES
end

step %{the following integration spec:} do |spec_content|
  write_file("spec/integration/whatever_spec.rb", <<-SPEC)
    require 'rails_helper'
    require 'capybara/rspec'
    require 'support/whatever'

    RSpec.describe "whatever", :type => :feature do
      it "does the thing" do
        #{spec_content}
      end
    end
  SPEC
end

step %{the following spec supporter:} do |support_content|
  write_file("spec/support/whatever.rb", support_content)
end

step %{the integration spec should pass} do
  run_simple("bundle exec rspec spec/integration", false)
  expect(last_command_started).to have_output(/1 example, 0 failures/)
  expect(last_command_started).to have_exit_status(0)
end

step %{the SuccessAPI is installed} do
  write_file('app/models/success_api.rb', <<-SUCCESS_API)
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
  SUCCESS_API
end
