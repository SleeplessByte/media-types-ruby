# frozen_string_literal: true

require_relative '../../test_helper'

module MediaTypes
  module Dsl
    class ConfigurationTest < Minitest::Test

      class TrivialSchema
        include MediaTypes::Dsl

        def self.organisation
          'example'
        end

        use_name 'test'

        validations do
          version 1 do
              attribute :foo_1, Numeric
          end

          version 2 do
              attribute :foo_2, Numeric
          end

          view 'raw' do
            version 2 do
              attribute :foo_raw, Numeric
            end
          end
        end
      end

      def test_configued_schema
        assert TrivialSchema.view('raw').version(2).valid?({foo_raw: 42})
        TrivialSchema.view('raw').version(2).to_s

        assert_raises do
          TrivialSchema.view('raw').version(1).valid?({})
        end
        assert TrivialSchema.view('raw').identifier
        assert TrivialSchema.available_validations.length == 3
        assert TrivialSchema.available_validations.first == TrivialSchema.version(1)
        assert TrivialSchema.version(1).available_validations.length == 1
        assert TrivialSchema.version(1).view('raw').available_validations.length == 0
      end

    end
  end
end
