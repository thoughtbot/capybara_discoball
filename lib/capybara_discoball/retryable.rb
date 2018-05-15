module Capybara
  module Discoball
    module Retryable
      def with_retries(retry_count, *rescuable_exceptions)
        yield
      rescue *rescuable_exceptions => e
        if retry_count > 0
          retry_count -= 1
          puts e.inspect if ENV.key?("DEBUG")
          retry
        else
          raise
        end
      end
    end
  end
end
