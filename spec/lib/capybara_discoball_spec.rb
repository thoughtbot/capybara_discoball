require "capybara_discoball"
require "net/http"
require "sinatra/base"

RSpec.describe Capybara::Discoball do
  it "spins up a server" do
    example_discoball_app = Class.new(Sinatra::Base) do
      get("/") { "success" }
    end

    server_url = described_class.spin(example_discoball_app)
    response = Net::HTTP.get(URI(server_url))

    expect(response).to eq "success"
  end
end
