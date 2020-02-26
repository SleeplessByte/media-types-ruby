# frozen_string_literal: true

require_relative '../test_helper'

module MediaTypes
  class ExampleTest < Minitest::Test
    class TestMediaType
      include MediaTypes::Dsl

      class << self
        protected

        def organisation
          'domain.test'
        end
      end

      use_name 'test'

      validations do
        suffix :xml
      end

    end

    def test_the_default_media_type
      assert_equal :xml, TestMediaType.to_constructable.suffix
      assert_equal format(
        'application/vnd.domain.test.%<type>s%<view>s+%<suffix>s',
        type: 'test',
        version: nil,
        view: nil,
        suffix: :xml
      ), TestMediaType.identifier
    end

    def test_alter_version_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s%<view>s+%<suffix>s',
        type: 'test',
        version: 1,
        view: nil,
        suffix: :json
      ), TestMediaType.to_constructable.version(1).to_s
    end

    def test_alter_view_mime_type
      assert_equal format(
        'application/vnd.domain.test.%<type>s.%<view>s+%<suffix>s',
        type: 'test',
        version: nil,
        view: 'custom',
        suffix: :json
      ), TestMediaType.to_constructable.view('custom').to_s
    end

    def test_alter_mime_type_chains
      assert_equal format(
        'application/vnd.domain.test.%<type>s.v%<version>s.%<view>s+%<suffix>s',
        type: 'test',
        version: 4,
        view: 'other',
        suffix: :json
      ), TestMediaType.to_constructable.view('other').version(4).to_s
    end

    %i[index collection create].each do |predefined|
      define_method format('test_mime_type_predefined_%<predefined>s', predefined: predefined) do
        assert_equal format(
          'application/vnd.domain.test.%<type>s.%<view>s+%<suffix>s',
          type: 'test',
          version: nil,
          view: predefined,
          suffix: :json
        ), TestMediaType.to_constructable.public_send(predefined).to_s
      end
    end
  end
end
