# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class OptionalTest < Minitest::Test

      class OptionalAttribute
        include MediaTypes::Dsl

        def self.organisation
          'trailervote'
        end

        use_name 'test'

        validations do
          attribute :bar
          attribute :foo, String, optional: true
        end
      end

      def test_optional_attribute
        assert OptionalAttribute.validatable?(OptionalAttribute.to_constructable), 'Expected media type to be validatable'
        assert OptionalAttribute.validate!(bar: 'string', foo: 'string'), 'Expected input to be valid'
        assert OptionalAttribute.validate!(bar: 'string'), 'Expected input to be valid'

        refute OptionalAttribute.valid?(bar: 'string', foo: { bar: 'string' }), 'Expected input to be invalid'
        refute OptionalAttribute.valid?(bar: 'string', foo: {}), 'Expected input to be invalid'
        refute OptionalAttribute.valid?(bar: 'string', foo: nil), 'Expected input to be invalid'
        refute OptionalAttribute.valid?(bar: 'string', foo: ['string']), 'Expected input to be invalid'
        refute OptionalAttribute.valid?({}), 'Expected input to be invalid'
      end

      class OptionalAttributeInsideAny
        include MediaTypes::Dsl

        def self.organisation
          'trailervote'
        end

        use_name 'test'

        validations do
          any do
            attribute :bar, Numeric, optional: true
          end
        end
      end

      def test_optional_attribute_inside_any
        assert OptionalAttributeInsideAny.validatable?(OptionalAttributeInsideAny.to_constructable),
               'Expected media type to be validatable'
        assert OptionalAttributeInsideAny.validate!(foo: { bar: 42 }, other: { bar: 43 }), 'Expected input to be valid'
        assert OptionalAttributeInsideAny.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        assert OptionalAttributeInsideAny.validate!(foo: {}), 'Expected input to be valid'

        refute OptionalAttributeInsideAny.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        refute OptionalAttributeInsideAny.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        refute OptionalAttributeInsideAny.valid?(foo: []), 'Expected input to be invalid'
        refute OptionalAttributeInsideAny.valid?(foo: [nil]), 'Expected input to be invalid'
        refute OptionalAttributeInsideAny.valid?(foo: nil), 'Expected input to be invalid'
      end

      class OptionalAttributeInsideCollection
        include MediaTypes::Dsl

        def self.organisation
          'trailervote'
        end

        use_name 'test'

        validations do
          collection :foo do
            attribute :bar, Numeric, optional: true
          end
        end
      end

      def test_optional_attribute_inside_collection
        assert OptionalAttributeInsideCollection.validatable?(OptionalAttributeInsideCollection.to_constructable),
               'Expected media type to be validatable'
        assert OptionalAttributeInsideCollection.validate!(foo: [{ bar: 42 }, { bar: 43 }]), 'Expected input to be valid'
        # Attribute bar is optional, leaving no required attributes, so it may be empty
        assert OptionalAttributeInsideCollection.validate!(foo: [{}]), 'Expected input to be valid'
        # Attribute bar is optional, leaving no required attributes, so there may be no items
        assert OptionalAttributeInsideCollection.validate!(foo: []), 'Expected input to be valid'

        # Don't allow nil items
        refute OptionalAttributeInsideCollection.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects bar to be Numeric
        refute OptionalAttributeInsideCollection.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
        # Expects foo to be an Array
        refute OptionalAttributeInsideCollection.valid?(foo: { bar: 42 }), 'Expected input to be invalid'
        # Expects foo to be an Array
        refute OptionalAttributeInsideCollection.valid?(foo: nil), 'Expected input to be invalid'
        # Expects foo
        refute OptionalAttributeInsideCollection.valid?({}), 'Expected input to be invalid'
      end

      class OptionalCollection
        include MediaTypes::Dsl

        def self.organisation
          'trailervote'
        end

        use_name 'test'

        validations do
          collection :foo, optional: true do
            attribute :bar, Numeric
          end
        end
      end

      def test_optional_collection
        assert OptionalCollection.validatable?(OptionalCollection.to_constructable),
               'Expected media type to be validatable'
        assert OptionalCollection.validate!(foo: [{ bar: 42 }, { bar: 43 }]), 'Expected input to be valid'
        # Foo is optional, leaving no required keys
        assert OptionalCollection.validate!({}), 'Expected input to be valid'

        # Expects bar to be Numeric
        refute OptionalCollection.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
        # Expects foo to be an Array
        refute OptionalCollection.valid?(foo: { bar: 42 }), 'Expected input to be invalid'
        # Expects foo not to be empty
        refute OptionalCollection.valid?(foo: []), 'Expected input to be invalid'
        # Expects element to have an attribute bar
        refute OptionalCollection.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects foo to be an Array
        refute OptionalCollection.valid?(foo: nil), 'Expected input to be invalid'
      end

      class OptionalAttributeInsideAttribute
        include MediaTypes::Dsl

        def self.organisation
          'trailervote'
        end

        use_name 'test'

        validations do
          attribute :foo do
            attribute :bar, Numeric, optional: true
          end
        end
      end

      def test_optional_attribute_inside_attribute
        assert OptionalAttributeInsideAttribute.validatable?(OptionalAttributeInsideAttribute.to_constructable),
               'Expected media type to be validatable'
        assert OptionalAttributeInsideAttribute.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        # Bar is optional, leaving no required keys
        assert OptionalAttributeInsideAttribute.validate!(foo: {}), 'Expected input to be valid'

        # Expects bar to be Numeric
        refute OptionalAttributeInsideAttribute.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        # Expects foo to be a Hash
        refute OptionalAttributeInsideAttribute.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        # Expects foo not to be empty
        refute OptionalAttributeInsideAttribute.valid?(foo: []), 'Expected input to be invalid'
        # Expects foo to be a Hash
        refute OptionalAttributeInsideAttribute.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects foo to be a Hash
        refute OptionalAttributeInsideAttribute.valid?(foo: nil), 'Expected input to be invalid'
      end

      class OptionalAttributeInsideOptionalAttribute
        include MediaTypes::Dsl

        def self.organisation
          'trailervote'
        end

        use_name 'test'

        validations do
          attribute :foo, optional: true do
            attribute :bar, Numeric, optional: true
          end
        end
      end

      def test_optional_attribute_inside_optional_attribute
        assert OptionalAttributeInsideOptionalAttribute.validatable?(OptionalAttributeInsideOptionalAttribute.to_constructable),
               'Expected media type to be validatable'
        assert OptionalAttributeInsideOptionalAttribute.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        # Bar is optional, leaving no required keys
        assert OptionalAttributeInsideOptionalAttribute.validate!(foo: {}), 'Expected input to be valid'
        # Foo is optional, leaving no required keys
        assert OptionalAttributeInsideOptionalAttribute.validate!({}), 'Expected input to be valid'

        # Expects bar to be Numeric
        refute OptionalAttributeInsideOptionalAttribute.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        # Expects foo to be a Hash
        refute OptionalAttributeInsideOptionalAttribute.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        # Expects foo not to be empty
        refute OptionalAttributeInsideOptionalAttribute.valid?(foo: []), 'Expected input to be invalid'
        # Expects foo to be a Hash
        refute OptionalAttributeInsideOptionalAttribute.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects foo to be a Hash
        refute OptionalAttributeInsideOptionalAttribute.valid?(foo: nil), 'Expected input to be invalid'
      end

      [OptionalAttribute,OptionalAttributeInsideAny,OptionalAttributeInsideCollection,OptionalCollection,OptionalAttributeInsideAttribute,OptionalAttributeInsideOptionalAttribute].each do |type|
       build_fixture_tests type  
      end
    end
  end
end
