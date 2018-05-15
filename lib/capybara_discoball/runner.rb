require "capybara"
require_relative "retryable"

module Capybara
  module Discoball
    class Runner
      include Capybara::Discoball::Retryable

      RETRY_COUNT = 3

      def initialize(server_factory, &block)
        @server_factory = server_factory
        @after_server = block || Proc.new {}
      end

      def boot
        with_webrick_runner do
          @server = Server.new(@server_factory.new)
          @server.boot
        end

        @after_server.call(@server)
        @server.url
      end

      private

      def with_webrick_runner
        default_server_process = Capybara.server
        Capybara.server = :webrick

        with_retries(RETRY_COUNT, Errno::EADDRINUSE) { yield }
      ensure
        Capybara.server = default_server_process
      end
    end
  end
end
