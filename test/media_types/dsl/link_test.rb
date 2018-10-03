# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class LinkTest < Minitest::Test

      class SingleLink
        include MediaTypes::Dsl

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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

        def self.base_format
          'application/vnd.trailervote.test'
        end

        media_type 'test'

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
    end
  end
end
