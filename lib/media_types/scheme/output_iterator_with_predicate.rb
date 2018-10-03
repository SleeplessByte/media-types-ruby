# frozen_string_literal: true

require 'media_types/scheme/enumeration_context'

module MediaTypes
  class Scheme
    class OutputIteratorWithPredicate

      class << self
        def call(*args, **opts, &block)
          new(*args, **opts).call(&block)
        end
      end

      def initialize(enumerable, options, rules:)
        self.enumerable = enumerable
        self.options = options
        self.rules = rules
      end

      ##
      # Mimics Enumerable#all? with mandatory +&block+
      #
      def call
        if hash?
          return iterate_hash { |*args, **opts| yield(*args, **opts) }
        end

        iterate { |*args, **opts| yield(*args, **opts) }
      end

      private

      attr_accessor :enumerable, :options, :rules

      def hash?
        enumerable.is_a?(::Hash) || enumerable.respond_to?(:key)
      end

      def iterate_hash
        context = EnumerationContext.new(rules: rules)

        enumerable.all? do |key, value|
          yield key, value, options: options, context: context.enumerate(key)
        end
      end

      def iterate(&block)
        Array(enumerable).each_with_index.all? do |array_like_element, i|
          OutputIteratorWithPredicate.call(array_like_element, options.trace(i), rules: rules, &block)
        end
      end
    end
  end
end
