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

  def test_cannot_specify_key_type_after_validation_block
    assert_raises do
      KeyTypeSpecifiedAfterValidationBlock.class_eval do
        expect_string_keys
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

  class StringAttributes; end

  def test_string_keys_are_accepted_attributes
    StringAttributes.class_eval do
      include MediaTypes::Dsl

      use_name 'test'

      validations do
        attribute 'name', String
      end
    end
  end

  class SymbolAttributes; end

  def test_symbol_keys_are_accepted_attributes
    StringAttributes.class_eval do
      include MediaTypes::Dsl

      use_name 'test'

      validations do
        attribute :name, String
      end
    end
  end

  class NoKeyTypeSpecifiedNotStrict
    include MediaTypes::Dsl

    def self.organisation
      'domain.test'
    end

    use_name 'test'

    validations do
      not_strict
    end
  end

  class StringKeyTypeSpecifiedNotStrict
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

  class SymbolKeyTypeSpecifiedNotStrict
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

  def test_validations_check_key_preference_when_no_key_type_specified
    assert NoKeyTypeSpecifiedNotStrict.valid?({ sym: 'test' }), 'Symbol keys should be accepted'
    refute NoKeyTypeSpecifiedNotStrict.valid?({ 'str' => 'test' }), 'Expecting symbol keys'
    refute StringKeyTypeSpecifiedNotStrict.valid?({ 'str' => 'test', :sym => 'test' }), 'Expecting string keys only'
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified
    assert SymbolKeyTypeSpecifiedNotStrict.valid?({ sym: 'test' }), 'Symbol keys should be accepted'
    refute SymbolKeyTypeSpecifiedNotStrict.valid?({ 'str' => 'test' }), 'Expected string keys to be disallowed'
    refute StringKeyTypeSpecifiedNotStrict.valid?({ 'str' => 'test', :sym => 'test' }), ''
  end

  def test_validations_check_key_preference_when_string_key_type_specified
    refute StringKeyTypeSpecifiedNotStrict.valid?({ sym: 'test' }), 'Expected symbol keys to be disallowed'
    assert StringKeyTypeSpecifiedNotStrict.valid?({ 'str' => 'test' }), 'Expected string key types to be accepted'
    refute StringKeyTypeSpecifiedNotStrict.valid?({ 'str' => 'test', :sym => 'test' }), 'Expected string keys only'
  end
end
