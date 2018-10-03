# frozen_string_literal: true

module MediaTypes
  class Scheme
    class EnumerationContext
      def initialize(rules:)
        self.rules = rules
      end

      def enumerate(val)
        self.key = val
        self
      end

      attr_accessor :rules, :key
    end
  end
end
