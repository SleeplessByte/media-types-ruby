# frozen_string_literal: true

require 'delegate'

module MediaTypes
  class Scheme
    # noinspection RubyInstanceMethodNamingConvention
    ##
    # Allows the wrapped +klazz+ to be nil
    #
    # @param [Class] klazz the class that +it+ must be the if +it+ is not NilClass
    # @return [CaseEqualityWithList]
    def AllowNil(klazz) # rubocop:disable Naming/MethodName
      AnyOf(NilClass, klazz)
    end
  end
end
