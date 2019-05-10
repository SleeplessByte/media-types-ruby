# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class CollectionTest < Minitest::Test

      class CollectionType
        include MediaTypes::Dsl

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

        scheme = MediaTypes::Scheme.new() do
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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

    end
  end
end
