capybara_discoball
==================

[![Build Status](https://travis-ci.org/thoughtbot/capybara_discoball.svg?branch=master)](https://travis-ci.org/thoughtbot/capybara_discoball)
[![Code Climate](https://codeclimate.com/github/thoughtbot/capybara_discoball/badges/gpa.svg)](https://codeclimate.com/github/thoughtbot/capybara_discoball)

Spin up a rack app just for Capybara.

This is useful for when ShamRack won't cut it: when your JavaScript hits
an external service, or you need to load an image or iframe from
elsewhere, or in general something outside of your Ruby code needs to
talk with an API.

Synopsis
--------

```ruby
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
  MusicDB.endpoint_url = server.url
end
```

More details
------------

You can instantiate a `Capybara::Discoball::Runner`, passing in a
factory which will create a Rack app:

```ruby
FakeMusicDBRunner = Capybara::Discoball::Runner.new(FakeMusicDB) do
  # tests to perform after server boot
end
```

This gives you back a runner, which you can boot from your features,
specs, tests, console, whatever:

```ruby
FakeMusicDBRunner.boot
```

These two steps can be merged with the `spin` class method:

```ruby
Capybara::Discoball.spin(FakeMusicDB) do
  # tests to perform while server is spinning
end
```

It is always the case that you need to know the URL for the external
API. We provide a way to access that URL; in fact, we offer the whole
`Capybara::Server` for you to play with. In this example, we are using
some `MusicDB` library in the code that knows to hit the
`.endpoint_url`:

```ruby
FakeMusicDBRunner = Capybara::Discoball::Runner.new(FakeMusicDB) do |server|
  MusicDB.endpoint_url = server.url
end
```

If no block is provided, the URL is also returned by `#spin`:

```ruby
MusicDB.endpoint_url = Capybara::Discoball.spin(FakeMusicDB)
```

Integrating into your app
-------------------------

All of this means that you must be able to set the endpoint URL. There
are two tricky cases:

*When the third-party library does not have hooks to set the endpoint
URL*.

Open the class and add the hooks yourself. This requires understanding
the source of the library. Here's an example where the library uses
`@@endpoint_url` everywhere to refer to the endpoint URL:

```ruby
class MusicDB
  def self.endpoint_url=(endpoint_url)
    @@endpoint_url = endpoint_url
  end
end
```

*When your JavaScript needs to talk to the endpoint URL*.

For this you must thread the URL through your app so that the JavaScript
can find it:

```ruby
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
```

Contributing
------------

See the [CONTRIBUTING] document. Thank you, [contributors]!

[CONTRIBUTING]: /CONTRIBUTING.md
[contributors]: https://github.com/thoughtbot/capybara_discoball/graphs/contributors

License
-------

capybara_discoball is Copyright (c) 2012-2015 thoughtbot, inc. It is free software,
and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE

About
-----

![thoughtbot](https://thoughtbot.com/logo.png)

capybara_discoball is maintained and funded by thoughtbot, inc.
The names and logos for thoughtbot are trademarks of thoughtbot, inc.

We love open source software!
See [our other projects][community]
or [hire us][hire] to help build your product.

[community]: https://thoughtbot.com/community?utm_source=github
[hire]: https://thoughtbot.com/hire-us?utm_source=github
