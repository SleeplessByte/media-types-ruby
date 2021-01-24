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
end
