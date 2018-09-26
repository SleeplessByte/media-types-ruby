# frozen_string_literal: true

require 'delegate'

module MediaTypes
  class Scheme
    class CaseEqualityWithNil < SimpleDelegator
      def ===(other)
        other.nil? || super
      end
    end

    # noinspection RubyInstanceMethodNamingConvention
    def AllowNil(klazz) # rubocop:disable Naming/MethodName
    CaseEqualityWithNil.new(klazz)
    end
  end
end
