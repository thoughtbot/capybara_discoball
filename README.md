`capybara_discoball`
==================

Spin up a rack app just for Capybara.

This is useful for when ShamRack won't cut it: when your JavaScript hits
an external service, or you need to load an image or iframe from
elsewhere, or in general something outside of your Ruby code needs to
talk with an API.

Synopsis
--------

    # Use Sinatra, for example
    require 'sinatra/base'
    require 'capybara_discoball'

    # Define a quick Rack app
    class FakeMusicDB < Sinatra::Base
      cattr_reader :albums

      get '/musicians/:musician/albums' do |musician|
        <<-XML
        <albums for="#{musician}">
          #{@albums.map { |album| "<album>#{album}</album>" }.join}
        </albums>
        XML
      end
    end

    # Spin up the Rack app, then update the imaginary library we're
    # using to point to the new URL.
    Capybara::Discoball.spin(FakeMusicDB) do |server|
      MusicDB.endpoint_url = server.url('/')
    end

More details
------------

You can instantiate a `Capybara::Discoball::Runner`, passing in a
factory which will create a Rack app:

    FakeMusicDBRunner = Capybara::Discoball::Runner.new(FakeMusicDB)

This gives you back a runner, which you can boot from your features,
specs, tests, console, whatever:

    FakeMusicDBRunner.boot

These two steps can be merged with the `spin` class method:

    Capybara::Discoball.spin(FakeMusicDB)

It is always the case that you need to know the URL for the external
API. We provide a way to access that URL; in fact, we offer the whole
`Capybara::Server` for you to play with. In this example, we are using
some `MusicDB` library in the code that knows to hit the
`.endpoint_url`:

    FakeMusicDBRunner = Capybara::Discoball::Runner.new(FakeMusicDB) do |server|
      MusicDB.endpoint_url = server.url('/')
    end

Integrating into your app
-------------------------

All of this means that you must be able to set the endpoint URL. There
are two tricky cases:

*When the third-party library does not have hooks to set the endpoint
URL*.

Open the class and add the hooks yourself. This requires understanding
the source of the library. Here's an example where the library uses
`@@endpoint_url` everywhere to refer to the endpoint URL:

    class MusicDB
      def self.endpoint_url=(endpoint_url)
        @@endpoint_url = endpoint_url
      end
    end

*When your JavaScript needs to talk to the endpoint URL*.

For this you must thread the URL through your app so that the JavaScript
can find it:

    <% content_for :javascript do %>
      <% javascript_tag do %>
        albumShower = new AlbumShower(<%= MusicDB.endpoint_url.to_json %>);
        albumShower.show();
      <% end %>
    <% end %>

    class @AlbumShower
      constructor: (@endpointUrl) ->
      show: ->
        $.get(@endpointUrl, (data) -> $('#albums').html(data))

Contributing
------------

We love pull requests.

1. Fork the repo.
2. Make a feature branch.
3. Write tests.
4. Implement the feature/bugfix.
5. Rebase and squash.
6. Submit the pull request.

License
-------

Copyright 2012 thoughtbot. Released under the same license as Ruby.
