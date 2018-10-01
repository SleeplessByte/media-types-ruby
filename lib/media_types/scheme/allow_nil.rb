# frozen_string_literal: true

require 'delegate'

module MediaTypes
  class Scheme
    class CaseEqualityWithNil < SimpleDelegator

      # Same as the wrapped {Object#===}, but also allows for NilCLass
      def ===(other)
        other.nil? || super
      end
    end

    # noinspection RubyInstanceMethodNamingConvention
    ##
    # Allows the wrapped +klazz+ to be nil
    #
    # @param [Class] klazz the class that +it+ must be the if +it+ is not NilClass
    # @return [CaseEqualityWithNil]
    def AllowNil(klazz) # rubocop:disable Naming/MethodName
      CaseEqualityWithNil.new(klazz)
    end
  end
end
