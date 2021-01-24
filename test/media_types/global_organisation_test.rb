# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  module OrganisationScope
    def media_types_organisation
      'longstring'
    end
    class GlobalOrganisationTest < Minitest::Test

      class AnyType
        include MediaTypes::Dsl

        use_name 'test'

        validations do
          empty
        end
      end

      def test_module_organisations
        MediaTypes.set_organisation MediaTypes::OrganisationScope.itself, 'universal.exports'
        assert_equal 'application/vnd.universal.exports.test+json', AnyType.identifier
      end

      module Acme
        MediaTypes.set_organisation Acme, 'acme'

        class FooValidator
          include MediaTypes::Dsl

          use_name 'foo'

          validations do
            attribute :foo, String
          end
        end
      end

      def test_readme_example
        assert_equal Acme::FooValidator.identifier, 'application/vnd.acme.foo+json'
      end

    end
  end
end
