# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class CollectionTest < Minitest::Test

      class CollectionType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'CollectionType'

        validations do
          collection :foo, Numeric
        end
      end

      def test_collection_of_type
        assert CollectionType.validatable?(CollectionType.to_constructable), 'Expected media type to be validatable'
        assert CollectionType.validate!(foo: [42, 43]), 'Expected input to be valid'

        refute CollectionCollectionType.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: {}), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: []), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: 42), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: [nil]), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: nil), 'Expected input to be invalid'
      end

      class CollectionCollectionType
        include MediaTypes::Dsl

        def self.organisation
          'domain.test'
        end

        use_name 'CollectionCollectionType'

        validations do
          collection :foo do
            attribute :bar, Numeric
          end
        end
      end

      def test_collection_with_block
        assert CollectionCollectionType.validatable?(CollectionCollectionType.to_constructable),
               'Expected media type to be validatable'
        assert CollectionCollectionType.validate!(foo: [{ bar: 42 }, { bar: 43 }]), 'Expected input to be valid'

        refute CollectionCollectionType.valid?(foo: [{ bar: 'string' }, { bar: 42 }]), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: [{ bar: 42, other: 43 }]), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: { bar: 42 }), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: {}), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: []), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: [nil]), 'Expected input to be invalid'
        refute CollectionCollectionType.valid?(foo: nil), 'Expected input to be invalid'
      end

      class CollectionSchemeType
        include MediaTypes::Dsl

        def self.organisation
          'domain.test'
        end

        use_name 'CollectionSchemeType'

        scheme = MediaTypes::Scheme.new do
          attribute :bar, Numeric
        end

        validations do
          collection :foo, scheme
        end
      end

      def test_collection_from_scheme
        assert CollectionSchemeType.validatable?(CollectionSchemeType.to_constructable),
               'Expected media type to be validatable'
        assert CollectionSchemeType.validate!(foo: [{ bar: 42 }, { bar: 43 }]), 'Expected input to be valid'

        refute CollectionSchemeType.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
        refute CollectionSchemeType.valid?(foo: [{ bar: 42, other: 43 }]), 'Expected input to be invalid'
        refute CollectionSchemeType.valid?(foo: { bar: 42 }), 'Expected input to be invalid'
        refute CollectionSchemeType.valid?(foo: {}), 'Expected input to be invalid'
        refute CollectionSchemeType.valid?(foo: []), 'Expected input to be invalid'
        refute CollectionSchemeType.valid?(foo: [nil]), 'Expected input to be invalid'
        refute CollectionSchemeType.valid?(foo: nil), 'Expected input to be invalid'
      end

      class CollectionSchemeTypeEmpty
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'CollectionSchemeTypeEmpty'

        scheme = MediaTypes::Scheme.new do
          attribute :bar, Numeric
        end

        validations do
          collection :foo, scheme, allow_empty: true
        end
      end

      def test_empty_collection_from_scheme
        assert CollectionSchemeTypeEmpty.validatable?(CollectionSchemeTypeEmpty.to_constructable),
               'Expected media type to be validatable'
        assert CollectionSchemeTypeEmpty.validate!(foo: []), 'Expected input to be valid'
      end

      class CollectionOptionsType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          collection :foo, Numeric, allow_empty: true
        end
      end

      def test_collection_with_options
        assert CollectionOptionsType.validatable?(CollectionOptionsType.to_constructable),
               'Expected media type to be validatable'
        assert CollectionOptionsType.validate!(foo: []), 'Expected input to be valid'
        assert CollectionOptionsType.validate!(foo: [42]), 'Expected input to be valid'

        refute CollectionOptionsType.valid?(foo: [{ bar: 42, other: 43 }]), 'Expected input to be invalid'
        refute CollectionOptionsType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute CollectionOptionsType.valid?(foo: {}), 'Expected input to be invalid'
        refute CollectionOptionsType.valid?(foo: [nil]), 'Expected input to be invalid'
        refute CollectionOptionsType.valid?(foo: nil), 'Expected input to be invalid'
      end

      class CollectionForceHashType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          collection :foo, expected_type: ::Hash do
            attribute :bar, Numeric
          end
        end
      end

      def test_collection_with_force
        assert CollectionForceHashType.validatable?(CollectionOptionsType.to_constructable),
               'Expected media type to be validatable'
        assert CollectionForceHashType.validate!(foo: { bar: 42 }), 'Expected input to be valid'

        refute CollectionForceHashType.valid?(foo: [{ bar: 42, other: 43 }]), 'Expected input to be invalid'
        refute CollectionForceHashType.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        refute CollectionForceHashType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute CollectionForceHashType.valid?(foo: {}), 'Expected input to be invalid'
        refute CollectionForceHashType.valid?(foo: []), 'Expected input to be invalid'
        refute CollectionForceHashType.valid?(foo: [nil]), 'Expected input to be invalid'
        refute CollectionForceHashType.valid?(foo: nil), 'Expected input to be invalid'
      end

      [CollectionType, CollectionCollectionType, CollectionSchemeType, CollectionSchemeTypeEmpty, CollectionOptionsType, CollectionForceHashType].each do |type|
        create_specification_tests_for type
      end

      class DuplicateSymbolSymbol; end

      def test_duplicate_collection_raises_error_for_case_symbol_symbol
        assert_raises Scheme::DuplicateSymbolKeyError do
          DuplicateSymbolSymbol.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              collection :foo, Numeric
              collection :foo, Numeric
            end
          end
        end
      end

      class DuplicateSymbolString; end

      def test_duplicate_collection_raises_error_for_case_symbol_string
        assert_raises Scheme::StringOverwritingSymbolError do
          DuplicateSymbolString.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              collection :foo, Numeric
              collection 'foo', Numeric
            end
          end
        end
      end

      class DuplicateStringSymbol; end

      def test_duplicate_collection_raises_error_for_case_string_symbol
        assert_raises Scheme::SymbolOverwritingStringError do
          DuplicateStringSymbol.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              collection 'foo', Numeric
              collection :foo, Numeric
            end
          end
        end
      end

      class DuplicateStringString; end

      def test_duplicate_collection_raises_error_for_case_string_string
        assert_raises Scheme::DuplicateStringKeyError do
          DuplicateStringString.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              collection 'foo', Numeric
              collection 'foo', Numeric
            end
          end
        end
      end

      class NonStringOrSymbolKeytype; end

      def test_non_string_or_symbol_collection_raises_keytype_error
        assert_raises Scheme::KeyTypeError do
          NonStringOrSymbolKeytype.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              collection Object, Numeric
            end
          end
        end
      end

      class TypeAndBlockCombined; end

      def test_collection_cannot_be_defined_with_both_a_type_and_a_block
        assert_raises Scheme::ConflictingTypeDefinitionError do
          TypeAndBlockCombined.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              collection :foo, Numeric do
              end
            end
          end
        end
      end

    end
  end
end
