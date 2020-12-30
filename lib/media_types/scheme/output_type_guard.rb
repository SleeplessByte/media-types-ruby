# frozen_string_literal: true

require 'media_types/scheme/errors'

module MediaTypes
  class Scheme
    class OutputTypeGuard
      class << self
        def call(*args, **opts, &block)
          new(*args, **opts).call(&block)
        end
      end

      def initialize(output, options, rules:)
        self.output = output
        self.options = options
        self.expected_type = rules.expected_type
      end

      def call
        return unless expected_type && !(expected_type === output) # rubocop:disable Style/CaseEquality
        raise_type_error!(type: output.class, backtrace: options.backtrace)
      end

      private

      attr_accessor :output, :options, :expected_type

      def raise_type_error!(type:, backtrace:)
        raise OutputTypeMismatch, format(
          'Expected a %<expected>s, got a %<actual>s at %<backtrace>s',
          expected: expected_type,
          actual: type,
          backtrace: backtrace.join('->')
        )
      end
    end
  end
end
