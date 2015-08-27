require "capybara"

module Capybara
  module Discoball
    class Runner
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

      def with_webrick_runner(&block)
        with_retries(RETRY_COUNT) { launch_webrick(&block) }
      end

      def with_retries(retry_count)
        yield
      rescue Errno::EADDRINUSE => e
        if retry_count > 0
          retry_count -= 1
          puts e.inspect
          retry
        else
          raise
        end
      end

      def launch_webrick
        default_server_process = Capybara.server
        Capybara.server = :webrick
        yield
      ensure
        Capybara.server = default_server_process
      end
    end
  end
end
