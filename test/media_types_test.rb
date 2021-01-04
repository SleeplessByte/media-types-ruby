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

  module TreeTestRoot; end
  @@tree_already_built = false
  def setup
    build_module_tree(TreeTestRoot) unless @@tree_already_built
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
  end

  private

  # Diagram
  #                    ---------->NoKeyTypeSpecified
  #                   |
  # parent module()-------------->StringKeyTypeSpecified
  #                  |
  #                  ------------->SymbolKeyTypeSpecified
  #
  # The method below builds out a tree, where the above depicts a single unit of the overall structure.
  # Each module gets all three possibilities nested in it and becomes a parent itself.

  def build_module_tree(target_module, depth = 1, module_tree = [])
    # This method creates a tree of nested modules, three levels deep,
    # with all combinations of key type inheritance covered.
    if depth >= 4
      @@tree_already_built = true
      return module_tree
    end

    # Creates three modules, with different key type specifications
    no_key_type_module = target_module.const_set('NoKeyTypeSpecified', Module.new)
    string_key_type_module = target_module.const_set('StringKeyTypeSpecified', Module.new)
    symbol_key_type_module = target_module.const_set('SymbolKeyTypeSpecified', Module.new)
    [no_key_type_module, string_key_type_module, symbol_key_type_module].each do |module_type|
      module_type.module_eval do
        if module_type.name.end_with?('StringKeyTypeSpecified')
          MediaTypes.expect_string_keys(self)
        elsif module_type.name.end_with?('SymbolKeyTypeSpecified')
          MediaTypes.expect_symbol_keys(self)
        end
      end
      module_tree << module_type
      target_media_type = Class.new
      module_type.const_set('TestMediaType', target_media_type)
      target_media_type.class_eval do
        include MediaTypes::Dsl

        def self.organisation
          'domain.test'
        end

        use_name 'test'

        validations do
          empty
        end
      end
      build_module_tree(module_type, depth + 1, module_tree)
    end
    module_tree
  end
end
