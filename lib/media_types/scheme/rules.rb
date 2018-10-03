# frozen_string_literal: true

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

      def merge(rules)
        __getobj__.merge!(rules)
        self
      end

      def inspect
        "[Scheme::Rules n=#{keys.length} default=#{default}]"
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
