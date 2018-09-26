# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class SchemeTest < Minitest::Test
    class TestMediaType < MediaTypes::Base
      class << self
        protected

        BASE_TEXT_FORMAT = 'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s'

        def base_format
          BASE_TEXT_FORMAT
        end
      end

      media_type 'scheme', suffix: :json, version: 2
      current_scheme do
        attribute :str, String
        attribute :maybe_num, AllowNil(Numeric)
        attribute :maybe_object, ::Object, allow_nil: true

        collection :collection do
          attribute :required, String
        end

        collection :open_collection do
          attribute :required, String
          not_strict
        end

        collection :maybe_empty_collection, allow_empty: true do
          attribute :required, String
        end

        collection :collection_with_unknown_keys do
          any do
            attribute :required, String
          end
        end
      end

      register_types :base_xml, view: 'x'

      register_additional_versions do
        version 1 do
          attribute :str, String
        end
      end
    end

    PASSING_DATA = {
      str: 'what',
      maybe_num: 42,
      maybe_object: { foo: :bar },

      collection: [
        { required: 'is' },
        { required: 'love' }
      ],

      open_collection: [
        { required: 'baby' },
        { required: 'don\'t', next: 'hurt' }
      ],

      maybe_empty_collection: [
        { required: 'me' },
        { required: 'don\'t' }
      ],

      collection_with_unknown_keys: {
        "hurt": { required: 'me' },
        "no": { required: 'more' }
      }
    }.freeze

    def test_it_validates
      assert TestMediaType.valid?(PASSING_DATA)
      assert TestMediaType.validate!(PASSING_DATA)
    end

    def test_it_is_strict_by_default
      assert_raises MediaTypes::StrictValidationError do
        TestMediaType.validate!(PASSING_DATA.dup.merge(boom: 'chakalaka'))
      end
    end

    def test_it_is_exhaustive_by_default
      assert_raises MediaTypes::ExhaustedOutputError do
        TestMediaType.validate!(MediaTypes::Hash.new(PASSING_DATA.dup).slice(:str, :maybe_num))
      end
    end

    def test_it_allows_nil_with_wrapper
      assert TestMediaType.validate!(PASSING_DATA.dup.merge(maybe_num: nil))
    end

    def test_it_allows_nil_with_option
      assert TestMediaType.validate!(PASSING_DATA.dup.merge(maybe_object: nil))
    end

    def test_it_allows_empty_collection_with_option
      assert TestMediaType.validate!(PASSING_DATA.dup.merge(maybe_empty_collection: []))
    end

    def test_it_allows_for_versioned_validation
      assert TestMediaType.validate!(MediaTypes::Hash.new(PASSING_DATA.dup).slice(:str), version: 1)
    end
  end
end
