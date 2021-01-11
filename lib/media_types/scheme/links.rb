# frozen_string_literal: true

require 'media_types/scheme/rules'
require 'media_types/scheme/rules_exhausted_guard'

module MediaTypes
  class Scheme
    class Links
      def initialize(expected_key_type:)
        self.links = Rules.new(allow_empty: false, expected_type: ::Hash, expected_key_type: expected_key_type)
      end

      def link(key, allow_nil: false, optional: false, &block)
        raise KeyTypeError, "Unexpected key type #{key.class.name}, please use either a symbol or string." unless key.is_a?(String) || key.is_a?(Symbol)
        raise DuplicateKeyError, "A link with the same string representation as the string '#{key}' already exists. Please remove one of the two." if links.has_key?(String(key).to_sym)
        links.add(
          key,
          Scheme.new(expected_key_type: self.links.expected_key_type) do
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
