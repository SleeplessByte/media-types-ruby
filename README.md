# MediaTypes

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'media_types'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install media_types

## Usage

By default there are no media types registered or defined, except for an abstract base type.

### Definition
You can define media types by inheriting from this base type, or create your own base type with a class method
`.base_format` that is used to create the final media type string by injecting formatted parameters:

- `%<type>s`: the type `media_type` received
- `%<version>s`: the version, defaults to `:current_version`
- `%<view>s`: the view, defaults to <empty>
- `%<suffix>s`: the suffix

```Ruby
require 'media_types'

class Venue < MediaTypes::Base
  media_type 'venue', suffix: :json, current_version: 2

  current_scheme do
    attribute :name, String
    collection :location do
      attribute :latitude, Numeric
      attribute :longitude, Numeric
      attribute :altitude, AllowNil(Numeric)
    end

    link :self
    link :route, allow_nil: true
  end

  register_types :venue_json do
    create     :create_venue_json
    index      :venue_urls_json
    collection :venue_collection_json
  end

  register_additional_versions do
    version 1 do
      attribute :name, String
      attribute :coords, String
      attribute :updated_at, String

      link :self
    end
  end
  
  def self.base_format
    'application/vnd.mydomain.%<type>s.v%<version>s%<view>s+%<suffix>s'
  end
end
```

### Schema Definitions

If you define a scheme using `current_scheme { }`, you may use any of the following dsl:

- `attribute(string, klazz)`: Adds an attribute to the scheme, with the type `klazz`
- `any(&block)`: Allow for any key, which then is validated against the block (which is a scheme).
- `collection(string, &block)`: Expect a collection such as an array or hash. If it's an array, each item is validated
against the block (which is a scheme). If it's a hash, the hash is validated against the block. If you want to force an
array or an object, prepend the collection by `attribute(string, Hash)` or `attribute(string, Array)`.
- `no_strict`: Can be added to a `scheme` such as the root, block inside `any` or block inside `collection` to allow for
undefined keys. If `no_strict` is not added, the block will not be valid if there are extra keys.
- `link(string)`: Example of a domain type. Each link is actually added to a scheme for `_links` on the current scheme.

If you want to compose types, you can wrap a klazz in `AllowNil(klazz)` to allow for nil values. This makes a validation
expected that klass, or nil.

You an add your own DSL by inspecting the `lib/media_types/scheme/<klazz>` classes.

### Validation
If your type has a schema, you can now use this media type for validation:

```Ruby
Venue.valid?({ ... })
# => true if valid, false otherwise

Venue.validate!({ ... })
# => raises if it's not valid
```

### Formatting for headers
Any media type object can be coerced in valid string to be used with `Content-Type` or `Accept`:

```Ruby

Venue.mime_type.to_s
# => "application/vnd.mydomain.venue.v2+json"

Venue.mime_type.version(1).to_s
# => "application/vnd.mydomain.venue.v1+json"

Venue.mime_type.version(1).suffix(:xml).to_s
# => "application/vnd.mydomain.venue.v1+xml"

Venue.mime_type.to_s(0.2)
# => "application/vnd.mydomain.venue.v2+json; q=0.2"

Venue.mime_type.collection.to_s
# => "application/vnd.mydomain.venue.v2.collection+json"

Venue.mime_type.view('active').to_s
# => "application/vnd.mydomain.venue.v2.active+json"
```

### Register in Rails or Rack
As long as `action_dispatch` is available, you can register the mime type with `action_dispatch/http/mime_type`:
```Ruby
Venue.register
# => Mime type is now available using the symbol, or lookup the actual mimetype
```

You can do this in the `mime_types` initializer, or anywhere before your controllers are instantiated. Yes, the symbol
(by default `<type>_v<version>_<suffix>`) can now be used in your `format` blocks, or as extension in the url.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can
also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the
version number in `version.rb`, and then run `bundle update media_types` in any repository that depends on
this gem. When the private gem server is set up you may call `bundle exec rake release` to create a new git tag, push 
git commits and tags, and push the `.gem` file to that private gem server.

## Contributing

Bug reports and pull requests are welcome on GitHub at [SleeplessByte/media_types-ruby](https://github.com/SleeplessByte/media_types-ruby)
