# frozen_string_literal: true

module MediaTypes
  class Scheme

    # Base class for all validations errors
    class ValidationError < ArgumentError; end

    # Raised when it did not expect more data, but there was more left
    class StrictValidationError < ValidationError; end

    # Raised when it expected not to be empty, but it was
    class EmptyOutputError < ValidationError; end

    # Raised when a value did not have the expected type
    class OutputTypeMismatch < ValidationError; end

    # Raised when it expected more data but there wasn't any left
    class ExhaustedOutputError < ValidationError; end
  end
end
