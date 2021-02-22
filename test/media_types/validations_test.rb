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

      freeze
    end

    def test_it_is_not_validatable
      assert_raises MediaTypes::Dsl::MissingValidationError do
        TestSchemeType.validatable?
      end
    end
  end
end
