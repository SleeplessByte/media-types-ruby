# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class AnyTest < Minitest::Test

      class AnyType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          any Numeric

          assert_pass <<-FIXTURE
          { "foo": 42, "bar": 43 }
          FIXTURE

          assert_pass '{"foo": 42}'
          # Any also means none, there are no required keys
          assert_pass '{}'

          # Expects any value to be a Numeric, not a Hash
          assert_fail <<-FIXTURE
          { "foo": { "bar": "string" } }
          FIXTURE

          # Expects any value to be Numeric, not a Hash
          assert_fail '{"foo": {}}'
          # Expects any value to be Numeric, not a NilClass
          assert_fail '{"foo": null}'
          # Expects any value to be Numeric, not Array
          assert_fail '{"foo": [42]}'
        end
      end

      def test_any_of_type
        assert AnyType.validatable?(AnyType.to_constructable), 'Expected media type to be validatable'
      end

      class AnyOfScheme
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          any do
            attribute :bar, Numeric
          end
        end
      end

      def test_any_of_scheme
        assert AnyOfScheme.validatable?(AnyOfScheme.to_constructable),
               'Expected media type to be validatable'
        assert AnyOfScheme.validate!(foo: { bar: 42 }, other: { bar: 43 }), 'Expected input to be valid'
        assert AnyOfScheme.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        # Any also means none, there are no required keys
        assert AnyOfScheme.validate!({}), 'Expected input to be valid'

        # Expects bar to be a number
        refute AnyOfScheme.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        # Expects a Hash
        refute AnyOfScheme.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        # Has a required rule
        refute AnyOfScheme.valid?(foo: {}), 'Expected input to be invalid'
        # Has a required rule
        refute AnyOfScheme.valid?(foo: []), 'Expected input to be invalid'
        # Expects a Hash
        refute AnyOfScheme.valid?(foo: nil), 'Expected input to be invalid'
        # Expects a Hash
        refute AnyOfScheme.valid?(foo: [nil]), 'Expected input to be invalid'
      end

      class AnyWithOptions
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          any allow_empty: true do
            attribute :bar, Numeric
          end
        end
      end

      def test_any_with_options
        assert AnyWithOptions.validatable?(AnyWithOptions.to_constructable),
               'Expected media type to be validatable'
        assert AnyWithOptions.validate!(foo: { bar: 42 }, other: { bar: 43 }), 'Expected input to be valid'
        assert AnyWithOptions.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        # Expects any value to be a Hash, but that Hash may be empty
        assert AnyWithOptions.validate!(foo: {}), 'Expect input to be valid'
        # Any also means none, there are no required keys
        assert AnyWithOptions.validate!({}), 'Expected input to be valid'

        # Expects bar to be Numeric
        refute AnyWithOptions.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptions.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptions.valid?(foo: []), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptions.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptions.valid?(foo: nil), 'Expected input to be invalid'
      end

      class AnyWithOptionsOrNil
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          # Same as AllowNil(::Hash)
          any allow_empty: true, expected_type: AnyOf(NilClass, ::Hash) do
            attribute :bar, Numeric
          end
        end
      end

      def test_any_with_options_or_nil
        assert AnyWithOptionsOrNil.validatable?(AnyWithOptionsOrNil.to_constructable),
               'Expected media type to be validatable'
        assert AnyWithOptionsOrNil.validate!(foo: { bar: 42 }, other: { bar: 43 }), 'Expected input to be valid'
        assert AnyWithOptionsOrNil.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        # Expects any value to be a Hash (or NilClass), but that Hash may be empty
        assert AnyWithOptionsOrNil.validate!(foo: {}), 'Expect input to be valid'
        # Expects any value to be a NilClass (or Hash)
        assert AnyWithOptionsOrNil.valid?(foo: nil), 'Expected input to be invalid'
        # Any also means none, there are no required keys
        assert AnyWithOptionsOrNil.validate!({}), 'Expected input to be valid'

        # Expects bar to be Numeric
        refute AnyWithOptionsOrNil.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptionsOrNil.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptionsOrNil.valid?(foo: []), 'Expected input to be invalid'
        # Expects any value to be a Hash
        refute AnyWithOptionsOrNil.valid?(foo: [nil]), 'Expected input to be invalid'
      end

      class AnyWithScheme
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        scheme = MediaTypes::Scheme.new(expected_type: ::Hash) do
          attribute :bar, Numeric
        end

        validations do
          any scheme
        end
      end

      def test_any_with_scheme
        assert AnyWithScheme.validatable?(AnyWithScheme.to_constructable),
               'Expected media type to be validatable'
        assert AnyWithScheme.validate!(foo: { bar: 42 }, other: { bar: 43 }), 'Expected input to be valid'
        assert AnyWithScheme.validate!(foo: { bar: 42 }), 'Expected input to be valid'
        # Any also means none, has no required parameters
        assert AnyWithScheme.validate!({}), 'Expect input to be valid'

        # Expects bar to be numeric
        refute AnyWithScheme.valid?(foo: { bar: 'string' }), 'Expected input to be invalid'
        # Expects any value to match scheme (thus be a Hash)
        refute AnyWithScheme.valid?(foo: [{ bar: 42 }]), 'Expected input to be invalid'
        # Expects any value to match scheme (thus have an attribute bar)
        refute AnyWithScheme.valid?(foo: {}), 'Expected input to be invalid'
        # Expects any value to match scheme (thus be a Hash)
        refute AnyWithScheme.valid?(foo: []), 'Expected input to be invalid'
        # Expects any value to match scheme (thus be a Hash)
        refute AnyWithScheme.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects any value to match scheme (thus be a Hash)
        refute AnyWithScheme.valid?(foo: nil), 'Expected input to be invalid'
      end

      class AnyWithForce
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'test'

        validations do
          any expected_type: ::Array do
            attribute :bar, Numeric
          end
        end
      end

      def test_any_with_force
        assert AnyWithForce.validatable?(AnyWithForce.to_constructable),
               'Expected media type to be validatable'
        assert AnyWithForce.validate!(foo: [{ bar: 42 }], other: [{ bar: 43 }]), 'Expected input to be valid'
        assert AnyWithForce.validate!(foo: [{ bar: 42 }]), 'Expected input to be valid'
        # Any also means none, has no required parameters
        assert AnyWithForce.validate!({}), 'Expect input to be valid'

        # Expects bar to be Numeric
        refute AnyWithForce.valid?(foo: [{ bar: 'string' }]), 'Expected input to be invalid'
        # Expects any value to be an Array
        refute AnyWithForce.valid?(foo: { bar: 42 }), 'Expected input to be invalid'
        # Don't allow nested arrays
        refute AnyWithForce.valid?(foo: [[{ bar: 42 }]]), 'Expected input to be invalid'
        # Expects any value to be an Array
        refute AnyWithForce.valid?(foo: {}), 'Expected input to be invalid'
        # Expects any value to be an Array with an attribute bar
        refute AnyWithForce.valid?(foo: []), 'Expected input to be invalid'
        # Expects any value to be an Array with an attribute bar
        refute AnyWithForce.valid?(foo: [nil]), 'Expected input to be invalid'
        # Expects any value to be an Array
        refute AnyWithForce.valid?(foo: nil), 'Expected input to be invalid'
      end

      [AnyType, AnyOfScheme, AnyWithOptions, AnyWithOptionsOrNil, AnyWithScheme, AnyWithForce].each do |type|
        assert_mediatype_specification type
      end
    end
  end
end
