require "capybara"

module Capybara
  module Discoball
    class Runner
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
        Capybara.server do |app, port|
          require "rack/handler/webrick"
          Rack::Handler::WEBrick.run(app, Port: port, AccessLog: [], Logger: WEBrick::Log::new(nil, 0))
        end
        yield
      ensure
        Capybara.server(&default_server_process)
      end
    end
  end
end
