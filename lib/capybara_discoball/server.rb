require "capybara/server"

module Capybara
  module Discoball
    class Server < ::Capybara::Server
      def url
        "http://#{host}:#{port}"
      end
    end
  end
end
