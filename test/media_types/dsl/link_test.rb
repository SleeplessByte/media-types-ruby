# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class LinkTest < Minitest::Test

      class SingleLink
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'SingleLink'

        validations do
          link :self
        end
      end

      def test_single_link
        assert SingleLink.validatable?(SingleLink.to_constructable), 'Expected media type to be validatable'
        assert SingleLink.validate!(_links: { self: { href: 'string' } }), 'Expected input to be valid'

        # Missing required link "self"
        refute SingleLink.valid?(_links: {}), 'Expected input to be invalid'
        # Expects href to be a String
        refute SingleLink.valid?(_links: { self: {} }), 'Expected input to be invalid'
        # Expects href to be a String
        refute SingleLink.valid?(_links: { self: { href: nil } }), 'Expected input to be invalid'
        # Missing required link self
        refute SingleLink.valid?({}), 'Expected input to be invalid'
      end

      class LinkWithAttribute
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'LinkWithAttribute'

        validations do
          link :self do
            attribute :templated, TrueClass
          end
        end
      end

      def test_link_with_attribute
        assert LinkWithAttribute.validatable?(LinkWithAttribute.to_constructable), 'Expected media type to be validatable'
        assert LinkWithAttribute.validate!(_links: { self: { href: 'string', templated: true } }), 'Expected input to be valid'

        # Missing required link "self"
        refute LinkWithAttribute.valid?(_links: {}), 'Expected input to be invalid'
        # Expects href to be a String
        refute LinkWithAttribute.valid?(_links: { self: {} }), 'Expected input to be invalid'
        # Expects href to be a String
        refute LinkWithAttribute.valid?(_links: { self: { href: nil } }), 'Expected input to be invalid'
        # Missing required attribute templated
        refute LinkWithAttribute.valid?(_links: { self: { href: 'string' } }), 'Expected input to be invalid'
        # Expects template to be a TrueClass
        refute LinkWithAttribute.valid?(_links: { self: { href: 'string', templated: false } }), 'Expected input to be invalid'
        # Missing required link self
        refute LinkWithAttribute.valid?({}), 'Expected input to be invalid'
      end

      class OptionalLink
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'OptionalLink'

        validations do
          link :self, optional: true
        end
      end

      def test_optional_link
        assert OptionalLink.validatable?(OptionalLink.to_constructable), 'Expected media type to be validatable'
        assert OptionalLink.validate!(_links: { self: { href: 'string' } }), 'Expected input to be valid'
        assert OptionalLink.validate!(_links: {}), 'Expected input to be valid'

        # Expects href to be a String
        refute OptionalLink.valid?(_links: { self: {} }), 'Expected input to be invalid'
        # Expects href to be a String
        refute OptionalLink.valid?(_links: { self: { href: nil } }), 'Expected input to be invalid'
        # Missing _links
        refute OptionalLink.valid?({}), 'Expected input to be invalid'
      end

      [SingleLink, LinkWithAttribute, OptionalLink].each do |type|
        assert_mediatype_specification type
      end

      class DuplicateSymbolSymbol; end

      def test_duplicate_link_raises_error_for_case_symbol_symbol
        assert_raises Scheme::DuplicateSymbolKeyError do
          DuplicateSymbolSymbol.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              link :foo
              link :foo
            end
          end
        end
      end

      class DuplicateSymbolString; end

      def test_duplicate_link_raises_error_for_case_symbol_string
        assert_raises Scheme::StringOverwritingSymbolError do
          DuplicateSymbolString.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              link :foo
              link 'foo'
            end
          end
        end
      end

      class DuplicateStringSymbol; end

      def test_duplicate_link_raises_error_for_case_string_symbol
        assert_raises Scheme::SymbolOverwritingStringError do
          DuplicateStringSymbol.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              link 'foo'
              link :foo
            end
          end
        end
      end

      class DuplicateStringString; end

      def test_duplicate_link_raises_error_for_case_string_string
        assert_raises Scheme::DuplicateStringKeyError do
          DuplicateStringString.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              link 'foo'
              link 'foo'
            end
          end
        end
      end

      class NonStringOrSymbolKeytype; end

      def test_non_string_or_symbol_link_raises_keytype_error
        assert_raises Scheme::KeyTypeError do
          NonStringOrSymbolKeytype.class_eval do
            include MediaTypes::Dsl

            def self.organisation
              'domain.test'
            end

            use_name 'test'

            validations do
              link Object
            end
          end
        end
      end
    end
  end
end
