# frozen_string_literal: true

module MediaTypes
  class Scheme
    class ValidationOptions
      attr_accessor :exhaustive, :strict, :backtrace, :context

      def initialize(context = {}, exhaustive: true, strict: true, backtrace: [])
        self.exhaustive = exhaustive
        self.strict = strict
        self.backtrace = backtrace
        self.context = context
      end

      def inspect
        "backtrack: #{backtrace.inspect}, strict: #{strict.inspect}, exhaustive: #{exhaustive}, current_obj: #{scoped_output.to_json}"
      end

      def scoped_output
        current = context

        backtrace.drop(1).first(backtrace.size - 2).each do |e|
          current = current[e] unless current.nil?
        end

        current
      end

      def with_backtrace(backtrace)
        ValidationOptions.new(context, exhaustive: exhaustive, strict: strict, backtrace: backtrace)
      end

      def trace(*traces)
        with_backtrace(backtrace.dup.concat(traces))
      end

      def exhaustive!
        ValidationOptions.new(context, exhaustive: true, strict: strict, backtrace: backtrace)
      end
    end
  end
end
