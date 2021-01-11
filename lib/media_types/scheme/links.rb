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
