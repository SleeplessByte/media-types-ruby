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

  class KeyTypeSpecifiedAfterValidationBlock
    include MediaTypes::Dsl

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

  def test_cannot_specify_key_type_after_validation_block
    assert_raises do
      KeyTypeSpecifiedAfterValidationBlock.class_eval do
        expect_string_keys
        # Class
        # Make it assert a specific error class
      end
    end

    assert_raises do
      KeyTypeSpecifiedAfterValidationBlock.class_eval do
        expect_symbol_keys
      end
    end
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

  class UnspecifiedKeysMediaType
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      empty
    end
  end

  def test_key_settings_for_a_media_type_have_to_precede_validations_being_called
    assert_raises do
      UnspecifiedKeysMediaType.class_eval do
        expect_string_keys
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

  class NoKeyTypeSpecifiedWithAttribute
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      attribute :foo, String
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
      attribute :foo, String
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
      attribute :foo, String
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

  def test_validations_check_key_preference_when_no_key_type_specified
    assert NoKeyTypeSpecifiedWithAttribute.valid?({ foo: 'test' }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 'test' })
    refute NoKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 'test', :foo => 'test' }), 'Expecting string keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified
    assert SymbolKeyTypeSpecifiedWithAttribute.valid?({ foo: 'test' }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 'test' }), 'Expected string keys to be disallowed'
    refute StringKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 'test', :foo => 'test' }), ''
  end

  def test_validations_check_key_preference_when_string_key_type_specified
    refute StringKeyTypeSpecifiedWithAttribute.valid?({ foo: 'test' }), 'Expected symbol keys to be disallowed'
    assert StringKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 'test' }), 'Expected string key types to be accepted'
    refute StringKeyTypeSpecifiedWithAttribute.valid?({ 'foo' => 'test', :sym => 'test' }), 'Expected string keys only'
  end
end
