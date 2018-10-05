# frozen_string_literal: true

require 'media_types/scheme/missing_validation'

module MediaTypes
  class Scheme
    class Rules < DelegateClass(::Hash)

      attr_reader :expected_type

      def initialize(allow_empty:, expected_type:)
        super({})

        self.allow_empty = allow_empty
        self.expected_type = expected_type
        self.optional_keys = []

        self.default = MissingValidation.new
      end

      def allow_empty?
        allow_empty
      end

      def [](key)
        __getobj__[normalize_key(key)]
      end

      def add(key, val, optional: false)
        normalized_key = normalize_key(key)
        __getobj__[normalized_key] = val
        optional_keys << normalized_key if optional

        self
      end

      def []=(key, val)
        add(key, val, optional: false)
      end

      def fetch(key, &block)
        __getobj__.fetch(normalize_key(key), &block)
      end

      def delete(key)
        __getobj__.delete(normalize_key(key))
        self
      end

      ##
      # Returns the keys that are not options
      #
      # @see #add
      # #see #merge
      #
      # @return [Array<Symbol>] required keys
      #
      def required
        clone.tap do |cloned|
          optional_keys.each do |key|
            cloned.delete(key)
          end
        end
      end

      def clone
        super.tap do |cloned|
          cloned.__setobj__(__getobj__.clone)
        end
      end

      ##
      # Merges another set of rules into a clone of this one
      #
      # @param [Rules, ::Hash] the other rules
      # @return [Rules] a clone
      #
      def merge(rules)
        clone.instance_exec do
          __setobj__(__getobj__.merge(rules))
          if rules.respond_to?(:optional_keys, true)
            optional_keys.push(*rules.send(:optional_keys))
          end

          self
        end
      end

      def inspect(indent = 0)
        prefix = '  ' * indent
        return "#{prefix}[Error]Depth limit reached[/Error]" if indent > 5_000

        [
          "#{prefix}[Rules n=#{keys.length} optional=#{optional_keys.length}]",
          "#{prefix}  #{inspect_format_attribute(indent, '*', default)}",
          *keys.map { |key| "#{prefix}  #{inspect_format_attribute(indent, key)}" },
          "#{prefix}[/Rules]"
        ].join("\n")
      end

      def inspect_format_attribute(indent, key, value = self[key])
        [
          [key.to_s, optional_keys.include?(key) && '(optional)' || nil].compact.join(' '),
          value.is_a?(Scheme) || value.is_a?(Rules) ? "\n#{value.inspect(indent + 2)}" : value.inspect
        ].join(': ')
      end

      alias get []
      alias remove delete

      private

      attr_accessor :allow_empty, :optional_keys
      attr_writer :expected_type

      def normalize_key(key)
        String(key).to_sym
      end
    end
  end
end
