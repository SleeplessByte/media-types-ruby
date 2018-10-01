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
