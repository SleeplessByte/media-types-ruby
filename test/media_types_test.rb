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

  # Test the default is a string
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

  # class KeyTypeSpecifiedAfterValidationBlock
  #   include MediaTypes::Dsl

  #   def self.organisation
  #     'domain.test'
  #   end

  #   use_name 'test'

  #   validations do
  #     empty
  #   end

  #   expect_string_keys
  # end
  # Supposed to FAIL!!!

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

  # Test that you can over-ride the default for a module
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

  # Check the media type over-rides the module
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

  # TODO: Should be in the previous(???)
  def test_symbol_keys_can_set_for_a_media_type
    assert StringKeyModuleToBeOverRidden::OverridingMediaType.symbol_keys?
    refute StringKeyModuleToBeOverRidden::OverridingMediaType.string_keys?

    refute SymbolKeyModuleToBeOverRidden::OverridingMediaType.symbol_keys?
    assert SymbolKeyModuleToBeOverRidden::OverridingMediaType.string_keys?
  end

  # Test Clashes
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
      endModuleTriesToSetKeyTypeTwice.module_eval('MediaTypes.expect_symbol_keys(self)')
    end
    assert_raises do
      MediaTypeTriesToSetKeyTypeTwice.class_eval do
        expect_string_keys
        expect_symbol_keys
      end
    end
  end
  # Test too late
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

  # Change to you cannot change for  a module once the default is used.
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
    assert NoKeyTypeSpecifiedNotStrict.valid?({ symbol: 'stuff' })
    refute NoKeyTypeSpecifiedNotStrict.valid?({ 'string' => 'stuff' })
    refute NoKeyTypeSpecifiedNotStrict.valid?({ 'string' => 'stuff', :symbol => 'stuff' })
  end

  def test_validations_check_key_preference_when_symbol_key_type_specified
    assert SymbolKeyTypeSpecifiedNotStrict.valid?({ symbol: 'stuff' })
    refute SymbolKeyTypeSpecifiedNotStrict.valid?({ 'string' => 'stuff' })
    refute SymbolKeyTypeSpecifiedNotStrict.valid?({ 'string' => 'stuff', :symbol => 'stuff' })
  end

  def test_validations_check_key_preference_when_string_key_type_specified
    refute StringKeyTypeSpecifiedNotStrict.valid?({ symbol: 'stuff' })
    assert StringKeyTypeSpecifiedNotStrict.valid?({ 'string' => 'stuff' })
    refute StringKeyTypeSpecifiedNotStrict.valid?({ 'string' => 'stuff', :symbol => 'stuff' })
  end

  module TreeTestRoot; end
  def setup
    build_module_tree(TreeTestRoot)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified)
   end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified)
   end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_NoKeyTypeSpecified_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_StringKeyTypeSpecified_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_NoKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_StringKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_NoKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_StringKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified)
  end

  def test_that_MediaTypesTest_TreeTestRoot_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_SymbolKeyTypeSpecified_has_the_expected_key_type_preference
    validate_module_inheritance(MediaTypesTest::TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified)
  end

  private

  def validate_module_inheritance(target_module)
    expected = (target_module.name.split('::') - [demodulize(NoKeyTypeSpecified)]).pop
    result = if expected == demodulize(StringKeyTypeSpecified)
               Kernel.const_get(target_module.name + '::TestMediaType').string_keys?
             else
               Kernel.const_get(target_module.name + '::TestMediaType').symbol_keys?
             end
    assert result, "expected #{target_module}, to only accept  the same key type as #{expected}"
  end

  # Diagram
  #                    ---------->NoKeyTypeSpecified
  #                   |
  # parent module()-------------->StringKeyTypeSpecified
  #                  |
  #                  ------------->SymbolKeyTypeSpecified
  # The method below builds out a tree, where the above depicts a single unit of the overall structure. Each module gets all three possibilities nested in it
  # and becomes a parent itself

  def build_module_tree(target_module, depth = 1, module_tree = [])
    # This method creates a tree of nested modules, three levels deep,
    # with all combinations of key type inheritance covered.
    if depth >= 4
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
      module_type.const_set('TestMediaType', target_media_type)
    end
    module_tree
  end

  def demodulize(mod)
    mod = mod.to_s
    if (i = mod.rindex('::'))
      mod[(i + 2)..-1]
    else
      mod
    end
  end
end
