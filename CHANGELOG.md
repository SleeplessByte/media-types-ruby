# 0.4.0

- Simplify `assert_media_type_format` by dumping views completely
- Add test for `merge`
- Add test for nested blocks in `validations` using `view` and `version` nesting
- Add test for `validatable?`
- Add block passing to `Scheme.new`

# 0.3.0

- Add `merge` dsl to merge two `Scheme`

# 0.2.6

- Change validation to accept both symbolised and stringified input ánd validations

# 0.2.5

- Add automatic require for `media_types/scheme/any_of`

# 0.2.4

- Change messages for `assert_media_types_registered` to be more informative and consistent

# 0.2.3

- Fix an issue with `Hash#compact` which was introduce in 2.4+. Now works with Ruby 2.3

# 0.2.2

- Fix an issue with `Registrar#versions`
- Fix link in the gemspec to Github

# 0.2.1

- Fix an issue with `Constructable#valid?` and `Constructable#validate!` 

# 0.2.0

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
 
# 0.1.0

:baby: initial release
