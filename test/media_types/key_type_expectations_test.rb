# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class KeyTypeExpectationsTest < Minitest::Test
    module TreeTestRoot; end
    @@tree_already_built = false
    def setup
      build_module_tree(TreeTestRoot) unless @@tree_already_built
    end

    def test_symbol_key_type_preference_is_always_inherited_as_expected
      assert TreeTestRoot::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.symbol_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::TestMediaType.symbol_keys?
    end

    def test_string_key_type_preference_is_always_inherited_as_expected
      assert TreeTestRoot::NoKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::NoKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::NoKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::StringKeyTypeSpecified::SymbolKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::NoKeyTypeSpecified::TestMediaType.string_keys?
      assert TreeTestRoot::SymbolKeyTypeSpecified::StringKeyTypeSpecified::StringKeyTypeSpecified::TestMediaType.string_keys?
    end

    private

    # The goal is to test that key type inheritance works for all orders of inheritance.
    # There are three possible settings that need to be inherited: NoKeyTypeSpecified, StringKeyTypeSpecified, SymbolKeyTypeSpecified
    # There are three ways in which a module can handle inheritance: being a parent, being a child, being both a parent and a child
    # This means there are a lot cases we need to test for. To simplify that, we create tree structure to cover every case.
    # Starting with a root node, an object with each of the three key type options are added.
    # For each of the three just added options, we add again a node for each of the three key type options
    # And for the nine options added in the previous step, we add again each of the three key type options
    # Now we test the inheritance for each node in the tree. If they all pass, we've tested every possible iteration of inheritance

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
end
