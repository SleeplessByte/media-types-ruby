# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class AttributeTest < Minitest::Test

      class AttributeType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'AttributeType'

        validations do
          attribute :foo, Numeric

          assert_pass '{"foo": 42}'
          assert_fail '{"foo": "string"}'
          assert_fail '{"foo": {}}'
          assert_fail '{"foo": null}'
          assert_fail '{"foo": [42]}'
        end
      end

      def test_attribute_as_type
        assert AttributeType.validatable?(AttributeType.to_constructable), 'Expected media type to be validatable'
      end

      class AttributeCollectionType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          attribute :foo do
            attribute :bar, Numeric
          end

          assert_pass '{"foo": {"bar": 42}}'
          assert_fail '{"foo": {"bar": "string"}}'
          assert_fail '{"foo": {}}'
          assert_fail '{"foo": null}'
          assert_fail '{"foo": [{ "bar": "string"}]}'
        end
      end

      def test_attribute_with_block
        assert AttributeCollectionType.validatable?(AttributeCollectionType.to_constructable),
               'Expected media type to be validatable'
      end

      class AttributeSchemeType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        scheme = MediaTypes::Scheme.new do
          attribute :bar, Numeric
        end

        validations do
          attribute :foo, scheme

          assert_pass '{"foo": {"bar": 42}}'
          assert_fail '{"foo": {"bar": "string"}}'
          assert_fail '{"foo": {}}'
          assert_fail '{"foo": null}'
          assert_fail '{"foo": [{"bar": "string"}]}'
        end
      end

      def test_attribute_from_scheme
        assert AttributeSchemeType.validatable?(AttributeSchemeType.to_constructable),
               'Expected media type to be validatable'
      end

      class AttributeOptionsType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'AttributeOptionsType'

        validations do
          attribute :foo, Numeric, allow_nil: true
        end
      end

      def test_attribute_with_options
        assert AttributeOptionsType.validatable?(AttributeOptionsType.to_constructable),
               'Expected media type to be validatable'
        assert AttributeOptionsType.validate!(foo: nil), 'Expected input to be valid'
        assert AttributeOptionsType.validate!(foo: 42), 'Expected input to be valid'

        refute AttributeOptionsType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute AttributeOptionsType.valid?(foo: {}), 'Expected input to be invalid'
        refute AttributeOptionsType.valid?(foo: [42]), 'Expected input to be invalid'
        refute AttributeOptionsType.valid?(foo: [nil]), 'Expected input to be invalid'
      end

      def test_indifferent_access
        refute AttributeType.valid?({ 'foo' => nil }), 'Expected input to be invalid'
        refute AttributeType.valid?({}), 'Expected input to be invalid'
      end

      [AttributeType, AttributeCollectionType, AttributeSchemeType, AttributeOptionsType].each do |type|
        assert_mediatype_specification type
      end
    
      class DuplicateSymbolSymbol; end

      def test_duplicate_attribute_raises_error_for_case_symbol_symbol
        assert_raises Scheme::DuplicateSymbolKeyError do
          DuplicateSymbolSymbol.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              attribute :foo, Numeric
              attribute :foo, Numeric
            end
          end
        end
      end

      class DuplicateteSymbolString; end

      def test_duplicate_attribute_raises_error_for_case_symbol_string
        assert_raises Scheme::StringOverSymbolError do
          DuplicateteSymbolString.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              attribute :foo, Numeric
              attribute 'foo', Numeric
            end
          end
        end
      end

      class DuplicateStringSymbol; end

      def test_duplicate_attribute_raises_error_for_case_string_symbol
        assert_raises Scheme::SymbolOverStringError do
          DuplicateStringSymbol.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              attribute 'foo', Numeric
              attribute :foo, Numeric
            end
          end
        end
      end

      class DuplicateStringString; end

      def test_duplicate_attribute_raises_error_for_case_string_string
        assert_raises Scheme::DuplicateStringKeyError do
          DuplicateStringString.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              attribute 'foo', Numeric
              attribute 'foo', Numeric
            end
          end
        end
      end

      class NonStringOrSymbolKeytype; end

      def test_non_string_or_symbol_attribute_raises_keytype_error
        assert_raises Scheme::KeyTypeError do
          NonStringOrSymbolKeytype.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'
            
            validations do
              attribute Object, Numeric
            end
          end
        end
      end
    end
  end
end
