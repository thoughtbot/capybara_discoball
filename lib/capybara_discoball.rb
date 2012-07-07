require 'capybara_discoball/version'
require 'capybara_discoball/runner'

module Capybara
  module Discoball
    def self.spin(app, &block)
      Runner.new(app, &block).boot
    end
  end
end
