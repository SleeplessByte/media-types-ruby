# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class ValidationsTest < Minitest::Test

    class TestSchemeType
      include MediaTypes::Dsl

      def self.base_format
        'application/vnd.domain.test.%<type>s.v%<version>s.%<view>s+%<suffix>s'
      end

      media_type 'scheme'

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
