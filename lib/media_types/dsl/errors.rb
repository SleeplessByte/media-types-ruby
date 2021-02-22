# frozen_string_literal: true

module MediaTypes
  module Dsl
    class UninitializedConstructable < RuntimeError
      def message
        'Unable to generate constructable without a name, make sure to have called `use_name(name)` before.'
      end
    end

    # Raised when an error occurs during setting expected key type
    class KeyTypeExpectationError < StandardError; end

    class MissingValidationError < StandardError; end

    class OrganisationNotSetError < StandardError; end
  end
end
