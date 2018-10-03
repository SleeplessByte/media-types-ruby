# frozen_string_literal: true

require 'delegate'

module MediaTypes
  class Scheme
    class CaseEqualityWithList < SimpleDelegator

      # True for Enumerable#any? {Object#===}
      def ===(other)
        any? { |it| it === other } # rubocop:disable Style/CaseEquality
      end

      def inspect
        "[Scheme::AnyOf(#{__getobj__})]"
      end
    end

    # noinspection RubyInstanceMethodNamingConvention
    ##
    # Allows +it+ to be any of the wrapped +klazzes+
    #
    # @param [Array<Class>] klazzes the classes that are valid for +it+
    # @return [CaseEqualityWithList]
    def AnyOf(*klazzes) # rubocop:disable Naming/MethodName
      CaseEqualityWithList.new(klazzes)
    end
  end
end
