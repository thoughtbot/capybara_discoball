Feature: Rails

  @disable-bundler
  Scenario: Using Discoball in a Rails app with a block
    Given I have a Rails application with Discoball installed
    And the SuccessAPI is installed
    And the following integration spec:
    """
    visit '/successes'
    expect(page).to have_content('success')
    """
    And the following controller action:
    """
    render :plain => SuccessAPI.get
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
      SuccessAPI.endpoint_url = server.url
    end
    """
    Then the integration spec should pass

  @disable-bundler
  Scenario: Using Discoball in a Rails app without a block
    Given I have a Rails application with Discoball installed
    And the SuccessAPI is installed
    And the following integration spec:
    """
    visit '/successes'
    expect(page).to have_content('success')
    """
    And the following controller action:
    """
    render :plain => SuccessAPI.get
    """
    And the following spec supporter:
    """
    require 'sinatra/base'
    require 'capybara_discoball'
    require 'success_api'

    class FakeSuccess < Sinatra::Base
      get('/') { 'success' }
    end

    SuccessAPI.endpoint_url = Capybara::Discoball.spin(FakeSuccess)
    """
    Then the integration spec should pass
