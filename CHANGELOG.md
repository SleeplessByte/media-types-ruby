# Changelog

## 2.3.2

- Fix that causes bailout in nested rule to stop validation altogether

## 2.3.1

- Fix build issue that caused debian package to be empty

## 2.3.0

- Add ability to define multiple versions using one block.
- Add `index` attribute type that automatically generates a link list compatible with media_types-serialization.
- Add support for `collection` to automatically look up a previously defined schema when passing a view.
- Add ability to mark certain attributes as optional when validating with `loose: true` and required otherwise.

## 2.2.0

- Change dependencies and build output to be debian compatible

## 2.1.1

- Fix Ruby 2.6 to 2.7 incompatible change

## 2.1.0

- Add `override_suffix` to force a specific suffix
- Fix all deprecation warnings

## 2.0.1

- Views can now be accessed indifferently.
- Attribute keys no longer match indifferently.
- Fixed infinite loop when validating non-hash, non-array items.

## 2.0.0

- Remove ability to set default suffix. All suffixes now default to `+json`.
- Suffixes are now set for a given view and version instead of as a block.
- Add `suffix :yoursuffix` command to override the default `:json` suffix.
- Remove defaults block.
- Remove registrations block.

## 1.0.0

- Add the ability to do inline tests when defining validations using `assert_pass '<json>'` and `assert_fail '<json>'`.
- `media_type` has been replaced with `use_name`.
- It is no longer possible to set a default version. Please use `version <x> do` instead.
- You no longer need to specify a custom format string. If you set an organisation with `def self.organisation` or set a module wide organisation with `MediaTypes::set_organisation <module>, '<organisation>'` the library will generate identifiers for you.
- `self.base_format` has been replaced by `identifier_format do |type:, view:, version:, suffix:|`.
- Add the `empty` validation to mark an empty object as valid.
- Add the `identifier` function to get the [Media Type Identifier](https://en.wikipedia.org/wiki/Media_type) for the validator.
- Add `version(x)` and `view(x)` functions.
- Add an `available_validations` functions that returns all defined validations.
- Fix an issue where validations could accidentally merge if defined with a bad `base_format`.
- Fix an issue where undefined validations would accept an empty object.

## 0.6.2

- Fix handling empty collections

## 0.6.1

- Fix no `validations` error on `validatable?` (now returns `false`)
- Update `bundler` to `2.x`

## 0.6.0

- Change default expected type for `attribute` to Object
- Remove default `actionpack` calls for `.register`
- Add integration for registering with `actionpack` (rails)
- Add integration for registering with `http` (http.rb)
- Fix stack overflow for cyclic schema

## 0.5.5

- Fix an issue with `attribute(optional:, &block)` not passing `optional:` to the created `collection`.

## 0.5.4

- Fix formatter reworked template when fields are not present

## 0.5.3

- Remove `require 'awesome_print'` in library code as it's marked as a development dependency onlvy

## 0.5.2

- Add requires in files with missing requires

## 0.5.1

- Fix merging optional attributes
- Change `#inspect` to look like a tree

## 0.5.0

- Change internal representation of key to symbol
- Change default type from `nil` to `Object`, removing special behaviour for nil
- Add `Rules` class to handle normalization of keys and handling `rules` (`Scheme`, `Attribute`, etc)
- Add guard classes to handle guard behaviour (`OutputEmptyGuard`, `OutputTypeGuard` and `RulesExhaustedGuard`)
- Add `optional:` keywords to most dsl (`attribute`, `collection`, `any`, `link`)
- Add `Formatter` class to handle formatting of the `Constructable#to_s`
- Add behaviour to strip leading dot (`.`) or plus (`+`) from `+%<var>` if `var` is nil, fixing weird media types
- Add behaviour to remove format variable values if format variable is not present, fixing warnings
- Add `inspect` for most public classes
- Add second argument for type or scheme to `any` dsl, mimicking `collection`
- Add tests for most dsl, common permutations
- Rename `force` to `expected_type`
- Remove `format_view` behaviour where it adds a dot (`.`) if a view is present
- Remove special iteration behaviour for `Links` (`link` dsl), allowing them to be optional, or non-exhaustive
- Raise error if `self.base_format` is not available at time of `Dsl.media_type` call
- Fix `expected_type` guard for arrays, nil, or arrays with nil.

## 0.4.1

- Use strings for `:_links`, matching the other validation keys

## 0.4.0

- Simplify `assert_media_type_format` by dumping views completely
- Add test for `merge`
- Add test for nested blocks in `validations` using `view` and `version` nesting
- Add test for `validatable?`
- Add block passing to `Scheme.new`

## 0.3.0

- Add `merge` dsl to merge two `Scheme`

## 0.2.6

- Change validation to accept both symbolised and stringified input ánd validations

## 0.2.5

- Add automatic require for `media_types/scheme/any_of`

## 0.2.4

- Change messages for `assert_media_types_registered` to be more informative and consistent

## 0.2.3

- Fix an issue with `Hash#compact` which was introduce in 2.4+. Now works with Ruby 2.3

## 0.2.2

- Fix an issue with `Registrar#versions`
- Fix link in the gemspec to Github

## 0.2.1

- Fix an issue with `Constructable#valid?` and `Constructable#validate!`

## 0.2.0

Breaking changes to update public API and usage

- Remove `Base` class (use `MediaTypes::Dsl` instead)
- Remove a lot of configuration options as they are deemed unneeded
- Remove `active_support` dependency
- Rename `ConstructableMimeType` to `Constructable`
- Moved global scheme types to `Scheme` as subtype
- Add `MediaTypes::Dsl`
- Add `validations` block to capture schemes
- Add `registrations` block to capture register intent
- Add `defaults` block to capture mime type defaults
- Add `MediaTypes.register` class method to call `Mime::Type.register`
- Add `Registerable` capture class
- Add type / base setting for `Constructable`
- Add versioned validations
- Add forced types of `collection`s
- Add `attribute` with block
- Add `EnumerationOfType` for schema typed arrays
- Add `AnyOf` for scheme enum types
- Add non-block calls for `Scheme` dsl
- Add yard documentation to `/docs`

## 0.1.0

:baby: initial release
