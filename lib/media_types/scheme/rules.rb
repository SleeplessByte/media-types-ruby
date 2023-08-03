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
        self.strict_keys = []
        self.original_key_type = {}

        self.default = MissingValidation.new
      end

      def allow_empty?
        allow_empty
      end

      def [](key)
        __getobj__[normalize_key(key)]
      end

      def add(key, val, optional: false)
        validate_input(key, val)

        normalized_key = normalize_key(key)
        __getobj__[normalized_key] = val
        if optional == :loose
          strict_keys << normalized_key
        else
          optional_keys << normalized_key if optional
        end
        original_key_type[normalized_key] = key.class

        self
      end

      def validate_input(key, val)
        raise KeyTypeError, "Unexpected key type #{key.class.name}, please use either a symbol or string." unless key.is_a?(String) || key.is_a?(Symbol)

        validate_key_name(key, val)
      end

      def validate_key_name(key, val)
        return unless has_key?(key)

        if key.is_a?(Symbol)
          duplicate_symbol_key_name(key, val)
        else
          duplicate_string_key_name(key, val)
        end
      end

      def duplicate_symbol_key_name(key, val)
        raise DuplicateSymbolKeyError.new(val.class.name.split('::').last, key) if get_original_key_type(key) == Symbol

        raise SymbolOverwritingStringError.new(val.class.name.split('::').last, key)
      end

      def duplicate_string_key_name(key, val)
        raise DuplicateStringKeyError.new(val.class.name.split('::').last, key) if get_original_key_type(key) == String

        raise StringOverwritingSymbolError.new(val.class.name.split('::').last, key)
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
      def required(loose:)
        clone.tap do |cloned|
          optional_keys.each do |key|
            cloned.delete(key)
          end
          if loose
            strict_keys.each do |key|
              cloned.delete(key)
            end
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
          if rules.respond_to?(:strict_keys, true)
            strict_keys.push(*rules.send(:strict_keys))
          end

          self
        end
      end

      def inspect(indent = 0)
        prefix = '  ' * indent
        return "#{prefix}[Error]Depth limit reached[/Error]" if indent > 5_000

        [
          "#{prefix}[Rules n=#{keys.length} optional=#{optional_keys.length} strict=#{strict_keys.length} allow_empty=#{allow_empty?}]",
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

      def has_key?(key)
        __getobj__.key?(normalize_key(key))
      end

      def get_original_key_type(key)
        raise format('Key %<key>s does not exist', key: key) unless has_key?(key)

        original_key_type[normalize_key(key)]
      end

      def default=(input_default)
        unless default.nil?
          raise DuplicateAnyRuleError if !(default.is_a?(MissingValidation) || default.is_a?(NotStrict)) && !(input_default.is_a?(MissingValidation) || input_default.is_a?(NotStrict))
          raise DuplicateNotStrictRuleError if default.is_a?(NotStrict) && input_default.is_a?(NotStrict)
          raise NotStrictOverwritingAnyError if !(default.is_a?(MissingValidation) || default.is_a?(NotStrict)) && input_default.is_a?(NotStrict)
          raise AnyOverwritingNotStrictError if default.is_a?(NotStrict) && !(input_default.is_a?(MissingValidation) || input_default.is_a?(NotStrict))
        end
        super(input_default)
      end

      alias get []
      alias remove delete

      private

      attr_accessor :allow_empty, :strict_keys, :optional_keys, :original_key_type
      attr_writer :expected_type

      def normalize_key(key)
        String(key).to_sym
      end
    end
  end
end
