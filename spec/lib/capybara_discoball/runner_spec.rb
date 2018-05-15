require "capybara_discoball"
require "sinatra/base"

RSpec.describe Capybara::Discoball::Runner do
  describe "when Capybara fails to find an unused port" do
    it "retries up to 3 times" do
      expected_url = "http://localhost:9999"

      allow(Capybara::Discoball::Server).to receive(:new).and_return(
        unbootable_server,
        unbootable_server,
        unbootable_server,
        bootable_server(url: expected_url),
      )

      runner = described_class.new(Sinatra::Base)

      expect(runner.boot).to eq expected_url
    end
  end

  private

  def bootable_server(url:)
    instance_double(Capybara::Discoball::Server, boot: nil, url: url)
  end

  def unbootable_server
    server = instance_double(Capybara::Discoball::Server)
    allow(server).to receive(:boot).and_raise(Errno::EADDRINUSE)
    server
  end
end
