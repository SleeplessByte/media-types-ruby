# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class BaseTest < Minitest::Test

    include MediaTypes::Assertions

    class TestMediaType < Base
      class << self
        protected

        BASE_TEXT_FORMAT = 'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s'

        def base_format
          BASE_TEXT_FORMAT
        end
      end

      media_type 'base', suffix: :xml, version: 2, aliases: ['base_test']

      register_types :base_xml, view: 'x' do |_|
        index :index_xml
        collection :collection_xml, version: 1
        create :create_json, suffix: :json, synonyms: ['application/vnd.domain.test.create.basic+xml']
        view('custom', :custom_json, suffix: :json)
      end

      register_additional_versions do
        version 1
      end
    end

    def test_the_default_media_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'base',
        version: 2,
        view: nil,
        suffix: :xml
      ), TestMediaType.mime_type.to_s
    end

    def test_alter_version_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'base',
        version: 1,
        view: nil,
        suffix: :xml
      ), TestMediaType.mime_type.version(1).to_s
    end

    def test_alter_suffix_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'base',
        version: 2,
        view: nil,
        suffix: :json
      ), TestMediaType.mime_type.suffix(:json).to_s
    end

    def test_alter_view_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'base',
        version: 2,
        view: '.custom',
        suffix: :xml
      ), TestMediaType.mime_type.view('custom').to_s
    end

    def test_alter_mime_type_chains
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'base',
        version: 4,
        view: '.other',
        suffix: :json
      ), TestMediaType.mime_type.view('other').version(4).suffix(:json).to_s
    end

    %i[index collection create].each do |predefined|
      define_method format('test_mime_type_predefined_%<predefined>s', predefined: predefined) do
        assert_equal format(
          'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
          type: 'base',
          version: 2,
          view: '.' + String(predefined),
          suffix: :xml
        ), TestMediaType.mime_type.public_send(predefined).to_s
      end
    end

    def test_it_registers
      assert_registered_types(
        TestMediaType,
        # Test base view modification
        'application/vnd.domain.test.base.v2.x+xml' => [
          :base_xml, ['application/vnd.domain.test.base_test.v2.x+xml']
        ],

        'application/vnd.domain.test.base.v1.x+xml' => [
          :base_xml_v1, ['application/vnd.domain.test.base_test.v1.x+xml']
        ],

        # Test default block type with view
        'application/vnd.domain.test.base.v2.index+xml' => [
          :index_xml, ['application/vnd.domain.test.base_test.v2.index+xml']
        ],

        'application/vnd.domain.test.base.v1.index+xml' => [
          :index_xml_v1, ['application/vnd.domain.test.base_test.v1.index+xml']
        ],

        # Test block type with pinned version
        'application/vnd.domain.test.base.v1.collection+xml' => [
          :collection_xml_v1, ['application/vnd.domain.test.base_test.v1.collection+xml']
        ],

        # Test block type with different suffix, and synonyms
        'application/vnd.domain.test.base.v2.create+json' => [
          :create_json, %w[application/vnd.domain.test.create.basic+xml application/vnd.domain.test.base_test.v2.create+json]
        ],

        'application/vnd.domain.test.base.v1.create+json' => [
          :create_json_v1, %w[application/vnd.domain.test.create.basic+xml application/vnd.domain.test.base_test.v1.create+json]
        ],

        # Test custom block type view
        'application/vnd.domain.test.base.v2.custom+json' => [
          :custom_json, ['application/vnd.domain.test.base_test.v2.custom+json']
        ],

        'application/vnd.domain.test.base.v1.custom+json' => [
          :custom_json_v1, ['application/vnd.domain.test.base_test.v1.custom+json']
        ]
      )
    end
  end
end
