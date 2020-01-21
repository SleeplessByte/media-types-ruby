# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class ValidationsTest < Minitest::Test

    class TestSchemeType
      include MediaTypes::Dsl

      def self.organisation
        'domain'
      end

      use_name 'scheme'

      defaults do
        version 2
        suffix :json
      end

      freeze
    end

    def test_it_is_not_validatable
      refute TestSchemeType.validatable?
    end
  end
end
