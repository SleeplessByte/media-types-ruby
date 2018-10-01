# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class BaseTest < Minitest::Test

    include MediaTypes::Assertions

    class TestMediaType
      include MediaTypes::Dsl

      class << self
        protected

        BASE_TEXT_FORMAT = 'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s'

        def base_format
          BASE_TEXT_FORMAT
        end
      end

      media_type 'test', defaults: { suffix: :xml, version: 2 }

      registrations :base do
        view 'collection', :tests
        view 'index', :test_urls
        view 'create', :create_test
        view 'custom', :custom_test

        type_alias 'test.alias'

        versions((1...2).to_a)

        suffix :json
        suffix :xml
      end
    end

    def test_the_default_media_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'test',
        version: 2,
        view: nil,
        suffix: :xml
      ), TestMediaType.to_constructable.to_s
    end

    def test_alter_version_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'test',
        version: 1,
        view: nil,
        suffix: :xml
      ), TestMediaType.to_constructable.version(1).to_s
    end

    def test_alter_suffix_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'test',
        version: 2,
        view: nil,
        suffix: :json
      ), TestMediaType.to_constructable.suffix(:json).to_s
    end

    def test_alter_view_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'test',
        version: 2,
        view: '.custom',
        suffix: :xml
      ), TestMediaType.to_constructable.view('custom').to_s
    end

    def test_alter_mime_type_chains
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'test',
        version: 4,
        view: '.other',
        suffix: :json
      ), TestMediaType.to_constructable.view('other').version(4).suffix(:json).to_s
    end

    %i[index collection create].each do |predefined|
      define_method format('test_mime_type_predefined_%<predefined>s', predefined: predefined) do
        assert_equal format(
          'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
          type: 'test',
          version: 2,
          view: '.' + String(predefined),
          suffix: :xml
        ), TestMediaType.to_constructable.public_send(predefined).to_s
      end
    end

    def test_it_registers
      assert_registered_types(
        TestMediaType,
        'application/vnd.domain.test.test.v2+xml' => [
          :base_v2_xml, ['application/vnd.domain.test.test.alias.v2+xml']
        ],

        'application/vnd.domain.test.test.v1+xml' => [
          :base_v1_xml, ['application/vnd.domain.test.test.alias.v1+xml']
        ],

        'application/vnd.domain.test.test.v2+json' => [
          :base_v2_json, ['application/vnd.domain.test.test.alias.v2+json']
        ],

        'application/vnd.domain.test.test.v1+json' => [
          :base_v1_json, ['application/vnd.domain.test.test.alias.v1+json']
        ],

        'application/vnd.domain.test.test.v2.index+xml' => [
          :test_urls_v2_xml, ['application/vnd.domain.test.test.alias.v2.index+xml']
        ],

        'application/vnd.domain.test.test.v1.index+xml' => [
          :test_urls_v1_xml, ['application/vnd.domain.test.test.alias.v1.index+xml']
        ],

        'application/vnd.domain.test.test.v2.index+json' => [
          :test_urls_v2_json, ['application/vnd.domain.test.test.alias.v2.index+json']
        ],

        'application/vnd.domain.test.test.v1.index+json' => [
          :test_urls_v1_json, ['application/vnd.domain.test.test.alias.v1.index+json']
        ],

        'application/vnd.domain.test.test.v2.create+xml' => [
          :create_test_v2_xml, ['application/vnd.domain.test.test.alias.v2.create+xml']
        ],

        'application/vnd.domain.test.test.v1.create+xml' => [
          :create_test_v1_xml, ['application/vnd.domain.test.test.alias.v1.create+xml']
        ],

        'application/vnd.domain.test.test.v2.create+json' => [
          :create_test_v2_json, ['application/vnd.domain.test.test.alias.v2.create+json']
        ],

        'application/vnd.domain.test.test.v1.create+json' => [
          :create_test_v1_json, ['application/vnd.domain.test.test.alias.v1.create+json']
        ],

        'application/vnd.domain.test.test.v2.collection+xml' => [
          :tests_v2_xml, ['application/vnd.domain.test.test.alias.v2.collection+xml']
        ],

        'application/vnd.domain.test.test.v1.collection+xml' => [
          :tests_v1_xml, ['application/vnd.domain.test.test.alias.v1.collection+xml']
        ],

        'application/vnd.domain.test.test.v2.collection+json' => [
          :tests_v2_json, ['application/vnd.domain.test.test.alias.v2.collection+json']
        ],

        'application/vnd.domain.test.test.v1.collection+json' => [
          :tests_v1_json, ['application/vnd.domain.test.test.alias.v1.collection+json']
        ],

        'application/vnd.domain.test.test.v2.custom+xml' => [
          :custom_test_v2_xml, ['application/vnd.domain.test.test.alias.v2.custom+xml']
        ],

        'application/vnd.domain.test.test.v1.custom+xml' => [
          :custom_test_v1_xml, ['application/vnd.domain.test.test.alias.v1.custom+xml']
        ],

        'application/vnd.domain.test.test.v2.custom+json' => [
          :custom_test_v2_json, ['application/vnd.domain.test.test.alias.v2.custom+json']
        ],

        'application/vnd.domain.test.test.v1.custom+json' => [
          :custom_test_v1_json, ['application/vnd.domain.test.test.alias.v1.custom+json']
        ]
      )
    end
  end
end
