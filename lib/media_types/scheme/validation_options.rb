# frozen_string_literal: true

module MediaTypes
  class Scheme
    class ValidationOptions
      attr_accessor :exhaustive, :strict, :backtrace

      def initialize(exhaustive: true, strict: true, backtrace: [])
        self.exhaustive = exhaustive
        self.strict = strict
        self.backtrace = backtrace
      end

      def inspect
        "backtrack: #{backtrace.inspect}, strict: #{strict.inspect}, exhaustive: #{exhaustive}"
      end

      def with_backtrace(backtrace)
        ValidationOptions.new(exhaustive: exhaustive, strict: strict, backtrace: backtrace)
      end

      def trace(*traces)
        with_backtrace(backtrace.dup.concat(traces))
      end

      def exhaustive!
        ValidationOptions.new(exhaustive: true, strict: strict, backtrace: backtrace)
      end
    end
  end
end
