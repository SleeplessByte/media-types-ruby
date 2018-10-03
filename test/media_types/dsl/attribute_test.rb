# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class AttributeTest < Minitest::Test

      class AttributeType
        include MediaTypes::Dsl

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

        validations do
          attribute :foo, Numeric
        end
      end

      def test_attribute_as_type
        assert AttributeType.validatable?(AttributeType.to_constructable), 'Expected media type to be validatable'
        assert AttributeType.validate!(foo: 42), 'Expected input to be valid'

        refute AttributeType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute AttributeType.valid?(foo: {}), 'Expected input to be invalid'
        refute AttributeType.valid?(foo: nil), 'Expected input to be invalid'
        refute AttributeType.valid?(foo: [42]), 'Expected input to be invalid'
      end

      class AttributeCollectionType
        include MediaTypes::Dsl

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

        validations do
          attribute :foo do
            attribute :bar, Numeric
          end
        end
      end

      def test_attribute_with_block
        assert AttributeCollectionType.validatable?(AttributeCollectionType.to_constructable),
               'Expected media type to be validatable'
        assert AttributeCollectionType.validate!(foo: { bar: 42 }), 'Expected input to be valid'

        refute AttributeCollectionType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute AttributeCollectionType.valid?(foo: {}), 'Expected input to be invalid'
        refute AttributeCollectionType.valid?(foo: nil), 'Expected input to be invalid'
        refute AttributeCollectionType.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
      end

      class AttributeSchemeType
        include MediaTypes::Dsl

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

        scheme = MediaTypes::Scheme.new do
          attribute :bar, Numeric
        end

        validations do
          attribute :foo, scheme
        end
      end

      def test_attribute_from_scheme
        assert AttributeSchemeType.validatable?(AttributeSchemeType.to_constructable),
               'Expected media type to be validatable'
        assert AttributeSchemeType.validate!(foo: { bar: 42 }), 'Expected input to be valid'

        refute AttributeSchemeType.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute AttributeSchemeType.valid?(foo: {}), 'Expected input to be invalid'
        refute AttributeSchemeType.valid?(foo: nil), 'Expected input to be invalid'
        refute AttributeSchemeType.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
      end

      class AttributeOptionsType
        include MediaTypes::Dsl

        def self.base_format
          'application/vnd.trailervote.test+%<suffix>s'
        end

        media_type 'test'

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

    end
  end
end
