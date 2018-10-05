# frozen_string_literal: true

require 'http/mime_type'
require 'oj'

module MediaTypes
  module HttpIntegration

    module_function

    def register(registerable)
      mime_type = registerable.to_s

      HTTP::MimeType.register_adapter mime_type, AdapterFor(registerable.media_type)
      HTTP::MimeType.register_alias mime_type, registerable.to_sym

      registerable.aliases.each do |alias_mime_type|
        HTTP::MimeType.register_alias mime_type, alias_mime_type
      end
    end

    class << self
      private

      # noinspection RubyInstanceMethodNamingConvention
      def AdapterFor(media_type) # rubocop:disable Naming/MethodName
        adapter_name = media_type.split(%r{[./_+-]}).map(&:capitalize).join('').tr('^A-z0-9', '_')

        adapter = MediaTypes::HttpIntegration.const_set(adapter_name, Module.new)
        adapter.define_singleton_method('encode') do |obj|
          media_type.validate!(obj)
          Oj.dump(obj, mode: :compat)
        end

        adapter.define_singleton_method('decode') do |str|
          Oj.load(str, mode: :strict).tap do |result|
            media_type.validate!(result)
          end
        end

        adapter
      end
    end
  end

  integrate HttpIntegration
end
