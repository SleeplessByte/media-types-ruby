# frozen_string_literal: true

require 'media_types/scheme/rules'
require 'media_types/scheme/rules_exhausted_guard'

module MediaTypes
  class Scheme
    class Links
      def initialize
        self.links = Rules.new(allow_empty: false, expected_type: ::Hash)
      end

      def link(key, allow_nil: false, optional: false, &block)
        raise KeyTypeError, "Unexpected key type #{key.class.name}, please use either a symbol or string." unless key.is_a?(String) || key.is_a?(Symbol)
        raise DuplicateKeyError, "A link with key :#{key} has already been defined. Please remove one of the two." if (key.is_a?(Symbol) && links.has_key?(key) == Symbol)
        raise DuplicateKeyError, "A link with key #{key} has already been defined. Please remove one of the two." if (key.is_a?(String) && links.has_key?(key) == String)
        raise DuplicateKeyError, "A link with a String type name and with the same string representation as the symbol :#{key} already exists. Please remove one of the two." if key.is_a?(Symbol) && links.has_key?(key) == String
        raise DuplicateKeyError, "A link with a Symbol type name and with the same string representation as the string '#{key}' already exists. Please remove one of the two." if key.is_a?(String) && links.has_key?(key) == Symbol

        links.add(
          key,
          Scheme.new do
            attribute :href, String, allow_nil: allow_nil
            instance_exec(&block) if block_given?
          end,
          optional: optional
        )

        self
      end

      def validate!(output, options, **_opts)
        RulesExhaustedGuard.call(output, options, rules: links)
      end

      def inspect
        "[Scheme::Links #{links.keys}]"
      end

      private

      attr_accessor :links
    end
  end
end
