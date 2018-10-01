module MediaTypes
  class Scheme
    class EnumerationContext
      def initialize(validations:)
        self.validations = validations
      end

      def enumerate(val)
        self.key = val
        self
      end

      attr_accessor :validations, :key
    end
  end
end
