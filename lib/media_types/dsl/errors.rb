# frozen_string_literal: true

module MediaTypes
  module Dsl
    module ClassMethods
      class UninitializedConstructable < RuntimeError
        def message
          'Constructable has not been initialized'
        end
      end

      # Raised when an error occurs during setting expected key type
      class KeyTypeExpectationError < StandardError; end
    end
  end
end
