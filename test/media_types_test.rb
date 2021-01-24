# frozen_string_literal: true

require_relative './test_helper'

class MediaTypesTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::MediaTypes::VERSION
  end

  def test_it_requires
    %i[
      Constructable
      Dsl
      Formatter
      Hash
      Object
      Scheme
      Validations
    ].each do |klazz|
      assert MediaTypes.const_defined?(klazz),
             format('Expected %<klazz>s to be required', klazz: klazz)
    end
  end

  class NoKeyTypeSpecified
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      empty
    end
  end

  class StringKeyTypeSpecified
    include MediaTypes::Dsl

    expect_string_keys

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      empty
    end
  end

  class SymbolKeyTypeSpecified
    include MediaTypes::Dsl

    expect_symbol_keys

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      empty
    end
  end

  # refactor media types to match above
  def test_by_default_the_key_type_expected_is_a_symbol
    assert NoKeyTypeSpecified.symbol_keys?
    refute NoKeyTypeSpecified.string_keys?
  end

  def test_can_set_a_media_type_to_expect_string_keys_outside_any_module
    refute StringKeyTypeSpecified.symbol_keys?
    assert StringKeyTypeSpecified.string_keys?
  end

  def test_can_set_a_media_type_to_expect_symbol_keys_outside_any_module
    assert SymbolKeyTypeSpecified.symbol_keys?
    refute SymbolKeyTypeSpecified.string_keys?
  end

  module ModuleSpecifiesStringKeys
    MediaTypes.expect_string_keys(self)

    class ShouldInheritKeyType
      include MediaTypes::Dsl

      def self.organisation
        'domain.test'
      end

      use_name 'test'

      validations do
        empty
      end
    end
  end

  def test_string_keys_can_be_set_for_a_module
    assert ModuleSpecifiesStringKeys::ShouldInheritKeyType.string_keys?
    refute ModuleSpecifiesStringKeys::ShouldInheritKeyType.symbol_keys?
  end

  module StringKeyModuleToBeOverRidden
    MediaTypes.expect_string_keys(self)

    class OverridingMediaType
      include MediaTypes::Dsl

      expect_symbol_keys

      def self.organisation
        'domain.test'
      end

      use_name 'test'

      validations do
        empty
      end
    end
  end

  module SymbolKeyModuleToBeOverRidden
    class OverridingMediaType
      include MediaTypes::Dsl

      expect_string_keys

      def self.organisation
        'domain.test'
      end

      use_name 'test'

      validations do
        empty
      end
    end
  end

  def test_symbol_keys_can_set_for_a_media_type
    assert StringKeyModuleToBeOverRidden::OverridingMediaType.symbol_keys?
    refute StringKeyModuleToBeOverRidden::OverridingMediaType.string_keys?

    refute SymbolKeyModuleToBeOverRidden::OverridingMediaType.symbol_keys?
    assert SymbolKeyModuleToBeOverRidden::OverridingMediaType.string_keys?
  end
  module ModuleTriesToSetKeyTypeTwice
    MediaTypes.expect_string_keys(self)
  end

  class MediaTypeTriesToSetKeyTypeTwice

    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Numeric
    end
  end

  def test_key_settings_cannot_be_altered_on_the_same_level_once_set
    assert_raises do
      ModuleTriesToSetKeyTypeTwice.module_eval('MediaTypes.expect_symbol_keys(self)')
    end
    assert_raises do
      MediaTypeTriesToSetKeyTypeTwice.class_eval do
        expect_string_keys
        expect_symbol_keys
      end
    end
  end

  module ModuleDefinesExpectationsAfterMediaTypes
    class ShouldExpectSymbols
      include MediaTypes::Dsl

      def self.organisation
        'domain.test'
      end

      use_name 'test'

      validations do
        empty
      end
    end

    MediaTypes.expect_string_keys(self)
  end

  def test_cannot_change_module_expectations_after_default_used
    assert_raises do
      ModuleDefinesExpectationsAfterMediaTypes.module_eval('MediaTypes.expect_string_keys(self)')
    end
  end

  class MultipleKeyTypesInValidationBlock; end

  def test_validation_block_is_indifferent_to_key_type_used
    MultipleKeyTypesInValidationBlock.class_eval do
      include MediaTypes::Dsl
      def self.organisation
        'domain.test'
      end

      use_name 'test'

      validations do
        attribute :foo, String
        attribute 'bar', String
      end
    end
    assert true
  rescue StandardError
    assert false, 'MediaType definition with multiple key types in Validation block was not acceptable'
  end

  ### Test keyword behaviour regarding expected key type ###

  #### Testing Attribute ####

  class NoKeyTypeSpecifiedWithAttribute
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Numeric
    end
  end

  class SymbolKeyTypeSpecifiedWithAttribute
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Numeric
    end
  end

  class StringKeyTypeSpecifiedWithAttribute
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Numeric
    end
  end

  def test_validations_check_key_preference_when_no_key_type_specified_attribute
    assert NoKeyTypeSpecifiedWithAttribute.valid?({ foo: 9 }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 9 }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 9, :foo => 9 }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified_attribute
    assert SymbolKeyTypeSpecifiedWithAttribute.valid?({ foo: 9 }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 9 }), 'Expected string keys to be disallowed'
    refute StringKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 9, :foo => 9 }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_string_key_type_specified_attribute
    refute StringKeyTypeSpecifiedWithAttribute.valid?({ foo: 9 }), 'Expected symbol keys to be disallowed'
    assert StringKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 9 }), 'Expected string key types to be accepted'
    refute StringKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 9, :foo => 9 }), 'Expected string keys only'
  end

  #### Testing Collection ####

  class NoKeyTypeSpecifiedWithCollection
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      collection :foo, Numeric
    end
  end

  class SymbolKeyTypeSpecifiedWithCollection
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      collection :foo, Numeric
    end
  end

  class StringKeyTypeSpecifiedWithCollection
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      collection :foo, Numeric
    end
  end

  def test_validations_check_key_preference_when_no_key_type_specified_collection
    assert NoKeyTypeSpecifiedWithCollection.valid?({ foo: [9, 99] }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedWithCollection.valid?({ 'foo' => [9, 99] }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithCollection.valid?({ 'foo' => [9, 99], :foo => [9, 99] }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified_collection
    assert SymbolKeyTypeSpecifiedWithCollection.valid?({ foo: [9, 99] }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedWithCollection.valid?({ 'foo' => [9, 99] }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithCollection.valid?({ 'foo' => [9, 99], :foo => [9, 99] }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_string_key_type_specified_collection
    refute StringKeyTypeSpecifiedWithCollection.valid?({ foo: [9, 99] }), 'Expected symbol keys to be disallowed'
    assert StringKeyTypeSpecifiedWithCollection.valid?({ 'foo' => [9, 99] }), 'Expected string key types to be accepted'
    refute StringKeyTypeSpecifiedWithCollection.valid?({ 'foo' => [9, 99], :foo => [9, 99] }), 'Expected string keys only'
  end

  #### Testing Link ####

  class NoKeyTypeSpecifiedWithLink
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      link :foo
    end
  end

  class SymbolKeyTypeSpecifiedWithLink
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      link :foo
    end
  end

  class StringKeyTypeSpecifiedWithLink
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      link :foo
    end
  end

  def test_validations_check_key_preference_when_no_key_type_specified_link
    refute NoKeyTypeSpecifiedWithLink.valid?({ '_links' => { 'foo' => { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithLink.valid?({ _links: { 'foo' => { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithLink.valid?({ '_links' => { foo: { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithLink.valid?({ _links: { foo: { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithLink.valid?({ '_links' => { 'foo' => { href: 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithLink.valid?({ _links: { 'foo' => { href: 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithLink.valid?({ '_links' =>  { foo: { href: 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    assert NoKeyTypeSpecifiedWithLink.valid?({ _links:      { foo: { href: 'https://example.org/s' } } }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedWithLink.valid?({ _links: { foo: { href: 'https://example.org/s' }, 'foo' => { href: 'https://image.org/i' } } }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified_link
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ '_links' =>  { 'foo' => { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ _links: { 'foo' => { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ '_links' => { foo: { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ _links: { foo: { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ '_links' => { 'foo' => { href: 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ _links: { 'foo' => { href: 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ '_links' =>  { foo: { href: 'https://example.org/s' } } }), 'Expected string keys to be disallowed'
    assert SymbolKeyTypeSpecifiedWithLink.valid?({ _links:      { foo: { href: 'https://example.org/s' } } }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedWithLink.valid?({ _links: { foo: { href: 'https://example.org/s' }, 'foo' => { href: 'https://image.org/i' } } }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_string_key_type_specified_linkrefute
    assert StringKeyTypeSpecifiedWithLink.valid?({ '_links' => { 'foo' => { 'href' => 'https://example.org/s' } } }), 'Expected string keys to be accepted'
    refute StringKeyTypeSpecifiedWithLink.valid?({ _links: { 'foo' => { 'href' => 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ '_links' => { foo: { 'href' => 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ _links: { foo: { 'href' => 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ '_links' => { 'foo' => { href: 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ _links: { 'foo' => { href: 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ '_links' =>  { foo: { href: 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ _links:      { foo: { href: 'https://example.org/s' } } }), 'Expected symbol keys to be disallowed'
    refute StringKeyTypeSpecifiedWithLink.valid?({ '_links' => { :foo => { 'href' => 'https://example.org/s' }, 'foo' => { 'href' => 'https://image.org/i' } } }), 'Expected string keys only'
  end

  #### Testing Any ####

  class NoKeyTypeSpecifiedWithAny
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      any Numeric
    end
  end

  class SymbolKeyTypeSpecifiedWithAny
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      any Numeric
    end
  end

  class StringKeyTypeSpecifiedWithAny
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      any Numeric
    end
  end

  def test_validations_check_key_preference_when_no_key_type_specified_any
    assert NoKeyTypeSpecifiedWithAny.valid?({ foo: 9 }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9 }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9, :foo => 42 }), 'Expecting symbol keys only'
    refute NoKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9, :bar => 42 }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified_any
    assert SymbolKeyTypeSpecifiedWithAny.valid?({ foo: 9 }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9 }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9, :foo => 42 }), 'Expecting symbol keys only'
    refute SymbolKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9, :bar => 42 }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_string_key_type_specified_any
    refute StringKeyTypeSpecifiedWithAny.valid?({ foo: 9 }), 'Expected symbol keys to be disallowed'
    assert StringKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9 }), 'Expected string key types to be accepted'
    refute StringKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9, :foo => 42 }), 'Expected string keys only'
    refute StringKeyTypeSpecifiedWithAny.valid?({ 'foo' => 9, :bar => 42 }), 'Expected string keys only'
  end

  #### Testing not_strict ####

  class NoKeyTypeSpecifiedWithNotStrict
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      not_strict
    end
  end

  class SymbolKeyTypeSpecifiedWithNotStrict
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      not_strict
    end
  end

  class StringKeyTypeSpecifiedWithNotStrict
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      not_strict
    end
  end

  def test_validations_check_key_preference_when_no_key_type_specified_not_strict
    assert NoKeyTypeSpecifiedWithNotStrict.valid?({ foo: 9 }), 'Any key should be accepted'
    assert NoKeyTypeSpecifiedWithNotStrict.valid?({ 'foo' => 9 }), 'Any key should be accepted'
    assert NoKeyTypeSpecifiedWithNotStrict.valid?({ 'foo' => 9, :foo => 42 }), 'Any key should be accepted'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified_not_strict
    assert SymbolKeyTypeSpecifiedWithNotStrict.valid?({ foo: 9 }), 'Any key should be accepted'
    assert SymbolKeyTypeSpecifiedWithNotStrict.valid?({ 'foo' => 9 }), 'Any key should be accepted'
    assert SymbolKeyTypeSpecifiedWithNotStrict.valid?({ 'foo' => 9, :foo => 42 }), 'Any key should be accepted'
  end

  def test_validations_check_key_preference_when_string_key_type_specified_not_strict
    assert StringKeyTypeSpecifiedWithNotStrict.valid?({ foo: 9 }), 'Any key should be accepted'
    assert StringKeyTypeSpecifiedWithNotStrict.valid?({ 'foo' => 9 }), 'Any key should be accepted'
    assert StringKeyTypeSpecifiedWithNotStrict.valid?({ 'foo' => 9, :foo => 42 }), 'Any key should be accepted'
  end

  #### Testing nested validation ####

  class NoKeyTypeSpecifiedWithNestedCollection
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      collection :foo do
        attribute :bar, Numeric
      end
    end
  end

  class SymbolKeyTypeSpecifiedWithNestedCollection
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      collection :foo do
        attribute :bar, Numeric
      end
    end
  end

  class StringKeyTypeSpecifiedWithNestedCollection
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      collection :foo do
        attribute :bar, Numeric
      end
    end
  end

  def test_validations_check_key_preference_when_no_key_type_nested_collection
    assert NoKeyTypeSpecifiedWithNestedCollection.valid?({ foo: [{ bar: 9 }] }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedWithNestedCollection.valid?({ foo: [{ 'bar' => 9 }] }), 'Expected string keys to be disallowed'
    refute NoKeyTypeSpecifiedWithNestedCollection.valid?({ foo: [{ bar: 9 }, { 'bar' => 42 }] }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_nested_collection
    assert SymbolKeyTypeSpecifiedWithNestedCollection.valid?({ foo: [{ bar: 9 }] }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedWithNestedCollection.valid?({ foo: [{ 'bar' => 9 }] }), 'Expected string keys to be disallowed'
    refute SymbolKeyTypeSpecifiedWithNestedCollection.valid?({ foo: [{ bar: 9 }, { 'bar' => 42 }] }), 'Expecting symbol keys only'
  end

  def test_validations_check_key_preference_when_string_key_type_nested_collection
    refute StringKeyTypeSpecifiedWithNestedCollection.valid?({ 'foo' => [{ bar: 9 }] }), 'Expected symbol keys to be disallowed'
    assert StringKeyTypeSpecifiedWithNestedCollection.valid?({ 'foo' => [{ 'bar' => 9 }] }), 'Expected string key types to be accepted'
    refute StringKeyTypeSpecifiedWithNestedCollection.valid?({ 'foo' => [{ bar: 9 }, { 'bar' => 9 }] }), 'Expected string keys only'
  end

  #### Testing that we ignore key types in data ####

  class NoKeyTypeSpecifiedWithKeyedData
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Hash
    end
  end

  class SymbolKeyTypeSpecifiedWithKeyedData
    include MediaTypes::Dsl
    expect_symbol_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Hash
    end
  end

  class StringKeyTypeSpecifiedWithKeyedData
    include MediaTypes::Dsl
    expect_string_keys
    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, Hash
    end
  end

  def test_validations_check_key_preference_when_no_key_type_specified_keyed_data
    assert NoKeyTypeSpecifiedWithKeyedData.valid?({ foo: { bar: 9 } }), 'Any key should be accepted'
    assert NoKeyTypeSpecifiedWithKeyedData.valid?({ foo: { 'bar' => 9 } }), 'Any key should be accepted'
    assert NoKeyTypeSpecifiedWithKeyedData.valid?({ foo: { 'bar' => 9, :bar => 42 } }), 'Any key should be accepted'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified_keyed_data
    assert SymbolKeyTypeSpecifiedWithKeyedData.valid?({ foo: { bar: 9 } }), 'Any key should be accepted'
    assert SymbolKeyTypeSpecifiedWithKeyedData.valid?({ foo: { 'bar' => 9 } }), 'Any key should be accepted'
    assert SymbolKeyTypeSpecifiedWithKeyedData.valid?({ foo: { 'bar' => 9, :bar => 42 } }), 'Any key should be accepted'
  end

  def test_validations_check_key_preference_when_string_key_type_specified_keyed_data
    assert StringKeyTypeSpecifiedWithKeyedData.valid?({ 'foo' => { bar: 9 } }), 'Any key should be accepted'
    assert StringKeyTypeSpecifiedWithKeyedData.valid?({ 'foo' => { 'bar' => 9 } }), 'Any key should be accepted'
    assert StringKeyTypeSpecifiedWithKeyedData.valid?({ 'foo' => { 'bar' => 9, :bar => 42 } }), 'Any key should be accepted'
  end
end
