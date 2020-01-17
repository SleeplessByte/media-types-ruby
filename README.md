# MediaTypes
[![Build Status](https://travis-ci.com/SleeplessByte/media-types-ruby.svg?branch=master)](https://travis-ci.com/SleeplessByte/media-types-ruby)
[![Gem Version](https://badge.fury.io/rb/media_types.svg)](https://badge.fury.io/rb/media_types)
[![MIT license](http://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT) 
[![Maintainability](https://api.codeclimate.com/v1/badges/6f2dc1fb37ecb98c4363/maintainability)](https://codeclimate.com/github/SleeplessByte/media-types-ruby/maintainability)

Media Types based on  scheme, with versioning, views, suffixes and validations. Integrations available for [Rails](https://github.com/rails/rails) / ActionPack and [http.rb](https://github.com/httprb/http).

This library makes it easy to define schemas that can be used to validate JSON objects based on their Content-Type.

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

Define a validation:

```ruby
require 'media_types'

class FooValidator
  include MediaTypes::Dsl

  def self.organisation
    'example'
  end

  use_name 'foo'

  validations do
    attribute :foo, String
  end
end
```

Validate an object:

```ruby
FooValidator.validate!({ foo: 'bar' })
```

## Full example

```Ruby
require 'media_types'

class Venue
  include MediaTypes::Dsl
  
  def self.organisation
    'mydomain'
  end
  
  media_type 'venue', defaults: { suffix: :json }

  validations do
    version 2 do
      attribute :name, String
      collection :location do
        attribute :latitude, Numeric
        attribute :longitude, Numeric
        attribute :altitude, AllowNil(Numeric)
      end

      link :self
      link :route, allow_nil: true
    end
    
    version 1 do
      attribute :name, String
      attribute :coords, String
      attribute :updated_at, String
    
      link :self
    end
    
    view 'create' do
      collection :location do
        attribute :latitude, Numeric
        attribute :longitude, Numeric
        attribute :altitude, AllowNil(Numeric)
      end
      
      version 1 do
        collection :location do
          attribute :latitude, Numeric
          attribute :longitude, Numeric
          attribute :altitude, AllowNil(Numeric)
        end
      end
    end
  end

  registrations :venue_json do
    view 'create', :create_venue
    view 'index', :venue_urls
    view 'collection', :venue_collection
    
    versions [1,2]
    
    suffix :json
    suffix :xml
  end
end
```

## Schema Definitions

If you include 'MediaTypes::Dsl' in your class you can use the following functions within a `validation do` block to define your schema:

### `attribute`

Adds an attribute to the schema, if a +block+ is given, uses that to test against instead of +type+

| param | type | description |
|-------|------|-------------|
| key | `Symbol` | the attribute name |
| opts | `Hash` | options to pass to `Scheme` or `Attribute` |
| type | `Class`, `===`, Scheme | The type of the value, can be anything that responds to `===`,  or scheme to use if no `&block` is given. Defaults to `Object` without a `&block` and to Hash with a `&block`. |
| optional: | `TrueClass`, `FalseClass` | if true, key may be absent, defaults to `false` |
| &block | `Block` | defines the scheme of the value of this attribute |

#### Add an attribute named foo, expecting a string
```Ruby
require 'media_types'

class MyMedia
  include MediaTypes::Dsl

  validations do
    attribute :foo, String
  end
end

MyMedia.valid?({ foo: 'my-string' })
# => true
```

####  Add an attribute named foo, expecting nested scheme

```Ruby
class MyMedia
 include MediaTypes::Dsl

 validations do
   attribute :foo do
     attribute :bar, String
   end
 end
end

MyMedia.valid?({ foo: { bar: 'my-string' }})
# => true
```

### `any`
Allow for any key. The `&block` defines the Schema for each value.

| param | type | description |
|-------|------|-------------|
| scheme | `Scheme`, `NilClass` | scheme to use if no `&block` is given |
| allow_empty: | `TrueClass`, `FalsClass` | if true, empty (no key/value present) is allowed |
| expected_type: | `Class`, | forces the validated value to have this type, defaults to `Hash`. Use `Object` if either `Hash` or `Array` is fine |
| &block | `Block` | defines the scheme of the value of this attribute |

#### Add a collection named foo, expecting any key with a defined value
```Ruby
class MyMedia
 include MediaTypes::Dsl

 validations do
   collection :foo do
     any do
       attribute :bar, String
     end
   end
 end
end

MyMedia.valid?({ foo: [{ anything: { bar: 'my-string' }, other_thing: { bar: 'other-string' } }] })
# => true
```` 

### `not_strict`
Allow for extra keys in the schema/collection even when passing `strict: true` to `#validate!`

#### Allow for extra keys in collection

```Ruby
class MyMedia
 include MediaTypes::Dsl

 validations do
   collection :foo do
     attribute :required, String
     not_strict
   end
 end
end

MyMedia.valid?({ foo: [{ required: 'test', bar: 42 }] })
# => true
``` 
  
### `collection`
Expect a collection such as an array or hash. The `&block` defines the Schema for each item in that collection.

| param | type | description |
|-------|------|-------------|
| key | `Symbol` | key of the collection (same as `#attribute`) |
| scheme | `Scheme`, `NilClass`, `Class` | scheme to use if no `&block` is given or `Class` of each item in the  |
| allow_empty: | `TrueClass`, `FalseClass` | if true, empty (no key/value present) is allowed |
| expected_type: | `Class`, | forces the validated value to have this type, defaults to `Array`. Use `Object` if either `Array` or `Hash` is fine. |
| optional: | `TrueClass`, `FalseClass` | if true, key may be absent, defaults to `false` |
| &block | `Block` | defines the scheme of the value of this attribute |


#### Collection with an array of string
```Ruby
class MyMedia
 include MediaTypes::Dsl

 validations do
   collection :foo, String
 end
end

MyMedia.valid?({ collection: ['foo', 'bar'] })
# => true
```

#### Collection with defined scheme

```Ruby
class MyMedia
 include MediaTypes::Dsl

 validations do
   collection :foo do
     attribute :required, String
     attribute :number, Numeric
   end
 end
end

MyMedia.valid?({ foo: [{ required: 'test', number: 42 }, { required: 'other', number: 0 }] })
# => true
```

### `link`

Expect a link with a required `href: String` attribute

| param | type | description |
|-------|------|-------------|
| key | `Symbol` | key of the link (same as `#attribute`) |
| allow_nil: | `TrueClass`, `FalseClass` | if true, value may be nil |
| optional: | `TrueClass`, `FalseClass` | if true, key may be absent, defaults to `false` |
| &block | `Block` | defines the scheme of the value of this attribute, in addition to the `href` attribute |

#### Links as defined in HAL, JSON-Links and other specs
```Ruby
class MyMedia
  include MediaTypes::Dsl

  validations do
    link :_self
    link :image
  end
end

MyMedia.valid?({ _links: { self: { href: 'https://example.org/s' }, image: { href: 'https://image.org/i' }} })
# => true
```

#### Link with extra attributes
```Ruby
class MyMedia
 include MediaTypes::Dsl

 validations do
   link :image do
     attribute :templated, TrueClass
   end
 end
end

MyMedia.valid?({ _links: { image: { href: 'https://image.org/{md5}', templated: true }} })
# => true
```

## Validation
If your type has a validations, you can now use this media type for validation:

```Ruby
Venue.valid?({
  #...
})
# => true if valid, false otherwise

Venue.validate!({
  # /*...*/ 
})
# => raises if it's not valid
```

If an array is passed, check the scheme for each value, unless the scheme is defined as expecting a hash:
```Ruby
expected_hash = Scheme.new(expected_type: Hash) { attribute(:foo) }
expected_object = Scheme.new { attribute(:foo) } 

expected_hash.valid?({ foo: 'string' })
# => true

expected_hash.valid?([{ foo: 'string' }])
# => false


expected_object.valid?({ foo: 'string' })
# => true

expected_object.valid?([{ foo: 'string' }])
# => true
```

## Formatting for headers
Any media type object can be converted in valid string to be used with `Content-Type` or `Accept`:

```Ruby
Venue.mime_type.identifier
# => "application/vnd.mydomain.venue.v2+json"

Venue.mime_type.version(1).identifier
# => "application/vnd.mydomain.venue.v1+json"

Venue.mime_type.version(1).suffix(:xml).identifier
# => "application/vnd.mydomain.venue.v1+xml"

Venue.mime_type.to_s(0.2)
# => "application/vnd.mydomain.venue.v2+json; q=0.2"

Venue.mime_type.collection.identifier
# => "application/vnd.mydomain.venue.v2.collection+json"

Venue.mime_type.view('active').identifier
# => "application/vnd.mydomain.venue.v2.active+json"
```

## Integrations
The integrations are not loaded by default, so you need to require them:
```ruby
# For Rails / ActionPack
require 'media_types/integrations/actionpack'

# For HTTP.rb
require 'media_types/integrations/http' 
```

Define a `registrations` block on your media type, indicating the symbol for the base type (`registrations :symbol do`) and inside use the registrations dsl to define which media types to register. `versions array_of_numbers` determines which versions, `suffix name` adds a suffix, `type_alias name` adds an alias and `view name, symbol` adds a view.

```Ruby
Venue.register
```

### Rails
Load the `actionpack` integration and call `.register` on all the media types you want to be available in Rails. You can do this in the `mime_types` initializer, or anywhere before your controllers are instantiated. Yes, the symbol (by default `<type>_v<version>_<suffix>`) can now be used in your `format` blocks, or as extension in the url.

Rails only has a default serializer for `application/json`, and content with your `+json` media types (or different once) will not be deserialized by default. A way to overcome this is to set the JSON parameter parser for all new symbols. `.register` gives you back an array of `Registerable` objects that responds to `#to_sym` to get that symbol.

```ruby
symbols = Venue.register.map(&:to_sym)

original_parsers = ActionDispatch::Request.parameter_parsers
new_parser = original_parsers[Mime[:json].symbol]
new_parsers = original_parsers.merge(Hash[*symbols.map { |s| [s, new_parser] }])
ActionDispatch::Request.parameter_parsers = new_parsers
```

If you want to validate the content-type and not have your errors be `Rack::Error` but be handled by your controllers, leave this out and add a `before_action` to your controller that deserializes + validates for you.

### HTTP.rb
Load the `http` integration and call `.register` on all media types you want to be able to serialize and deserialize. The media type validations will run both before serialization and after deserialization.

Currently uses `oj` under the hood and this can not be changed.

## API

A defined schema has the following functions available:

### `valid?`

Example: `Venue.valid?({ foo: 'bar' })`

Allows passing in validation options as a second parameter.

### `validate!`

Example: `Venue.validate!({ foo: 'bar' })`

Allows passing in validation options as a second parameter.

### `validatable?`

Example: `Venue.version(42).validatable?`

Tests wether the current configuration of the schema has a validation defined.

### `register`

Example: `Venue.register`

Registers the media type to the registry.

### `view`

Example: `Venue.view('create')`

Returns a schema validator configured with the specified view.

### `version`

Example: `Venue.version(42)`

Returns a schema validator configured with the specified version.

### `suffix`

Example: `Venue.suffix(:json)`

Returns a schema validator configured with the specified suffix.

### `identifier`

Example: `Venue.version(2).identifier` (returns `'application/vnd.application.venue.v2'`)

Returns the IANA compatible [Media Type Identifier](https://en.wikipedia.org/wiki/Media_type) for the configured schema.

### `available_validations`

Example: `Venue.available_validations`

Returns a list of all the schemas that are defined.

## Related

- [`MediaTypes::Serialization`](https://github.com/XPBytes/media_types-serialization): :cyclone: Add media types supported serialization using your favourite serializer
- [`MediaTypes::Validation`](https://github.com/XPBytes/media_types-validation): :heavy_exclamation_mark: Response validations according to a media-type

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, call `bundle exec rake release` to create a new git tag, push git commits and tags, and
push the `.gem` file to rubygems.org.

## Contributing

Bug reports and pull requests are welcome on GitHub at [SleeplessByte/media-types-ruby](https://github.com/SleeplessByte/media-types-ruby)
