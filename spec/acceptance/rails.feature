Feature: Rails

  @disable-bundler
  Scenario: Using Discoball in a Rails app
    Given I have a Rails application with Discoball installed
    And the SuccessAPI is installed
    And the following integration spec:
    """
    visit '/successes'
    page.should have_content('success')
    """
    And the following controller action:
    """
    render :text => SuccessAPI.get
    """
    And the following spec supporter:
    """
    require 'sinatra/base'
    require 'capybara_discoball'
    require 'success_api'

    class FakeSuccess < Sinatra::Base
      get('/') { 'success' }
    end

    Capybara::Discoball.spin(FakeSuccess) do |server|
      SuccessAPI.endpoint_url = server.url('/')
    end
    """
    Then the integration spec should pass
