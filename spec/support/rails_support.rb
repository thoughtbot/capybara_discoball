module RailsSupport
  def create_rails_app
    in_current_dir { FileUtils.rm_rf 'testapp' }
    run_simple 'bundle exec rails new testapp --skip-bundle --skip-test-unit'
    cd 'testapp'
    append_to_file('Gemfile', <<-GEMS)
      gem 'capybara_discoball', :path => '../../..'
      gem 'thin'
      gem 'therubyracer'
      gem 'sinatra'
    GEMS
  end
end
