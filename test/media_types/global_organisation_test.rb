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
        puts Module.nesting.map { |m| [m, m.method_defined?(:media_types_organisation)] }.to_s
        MediaTypes::set_organisation MediaTypes::OrganisationScope.itself, 'universal.exports'
        assert_equal AnyType.identifier, 'application/vnd.universal.exports.test'
      end

    end
  end
end
