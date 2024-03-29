# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class NotStrictTest < Minitest::Test

      class NotStrictType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'NotStrictType'

        validations do
          attribute :foo, Numeric
          not_strict
        end
      end

      def test_not_strict_at_root
        assert NotStrictType.validatable?(NotStrictType.to_constructable), 'Expected media type to be validatable'
        assert NotStrictType.validate!({ foo: 42, bar: 'string' }), 'Expected input to be valid'
        assert NotStrictType.validate!({ foo: 42 }), 'Expected input to be valid'

        refute NotStrictType.valid?({ foo: { bar: 'string' } }), 'Expected input to be invalid'
        refute NotStrictType.valid?({ foo: {} }), 'Expected input to be invalid'
        refute NotStrictType.valid?({ foo: nil }), 'Expected input to be invalid'
        refute NotStrictType.valid?({ foo: [42] }), 'Expected input to be invalid'
      end

      class NotStrictCollectionType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'NotStrictCollectionType'

        validations do
          collection :foo do
            attribute :bar, Numeric
            not_strict
          end
        end
      end

      def test_not_strict_in_collection
        assert NotStrictCollectionType.validatable?(NotStrictCollectionType.to_constructable),
               'Expected media type to be validatable'
        assert NotStrictCollectionType.validate!({ foo: [{ bar: 42 }, { bar: 43 }] }), 'Expected input to be valid'
        assert NotStrictCollectionType.validate!({ foo: [{ bar: 42, other: 43 }] }), 'Expected input to be valid'

        refute NotStrictCollectionType.valid?({ foo: [{ bar: 'string' }, { bar: 42 }] }), 'Expected input to be invalid'
        refute NotStrictCollectionType.valid?({ foo: { bar: 42 } }), 'Expected input to be invalid'
        refute NotStrictCollectionType.valid?({ foo: {} }), 'Expected input to be invalid'
        refute NotStrictCollectionType.valid?({ foo: [] }), 'Expected input to be invalid'
        refute NotStrictCollectionType.valid?({ foo: [nil] }), 'Expected input to be invalid'
        refute NotStrictCollectionType.valid?({ foo: nil }), 'Expected input to be invalid'
      end

      [NotStrictType, NotStrictCollectionType].each do |type|
        create_specification_tests_for type
      end

      class OverwritingNotStrictWithNotStrict; end

      def test_overwriting_not_strict_with_not_strict_raises_error
        assert_raises Scheme::DuplicateNotStrictRuleError do
          OverwritingNotStrictWithNotStrict.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              not_strict
              not_strict
            end
          end
        end
      end

      class OverwritingAnyWithNotStrict; end

      def test_overwriting_any_with_not_strict_raises_error
        assert_raises Scheme::NotStrictOverwritingAnyError do
          OverwritingAnyWithNotStrict.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              any Numeric
              not_strict
            end
          end
        end
      end
    end
  end
end
