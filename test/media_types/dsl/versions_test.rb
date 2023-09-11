# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class VersionsTestTest < Minitest::Test

      class AttributeType
        include MediaTypes::Dsl

        def self.organisation
          'acme'
        end

        use_name 'AttributeType'

        validations do
          versions [1,2] do |v|
            attribute :foo, Numeric
            attribute :bar, Numeric if v == 2
          end
        end
      end

      def test_versions
        assert AttributeType.version(1).valid?({ foo: 1 }), 'Version 1 should validate'
        
        assert AttributeType.version(2).valid?({ foo: 1, bar: 42 }), 'Version 2 should validate'
        refute AttributeType.version(1).valid?({ foo: 1, bar: 42 }), 'bar should only exist in version 2'
      end
    end
  end
end
