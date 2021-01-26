# frozen_string_literal: true

module MediaTypes
  class Scheme

    # Base class for all validations errors
    class ValidationError < ArgumentError; end

    # Raised when trying to register an attribute with a non-string key
    class KeyTypeError < ArgumentError; end

    # Raised when trying to register a key twice
    class DuplicateKeyError < ArgumentError; end

    class DuplicateSymbolKeyError < DuplicateKeyError
      MESSAGE_TEMPLATE = '%<rule_type>s rule with key :%<key>s has already been defined. Please remove one of the two.'

      def initialize(rule_type, key)
        super(format(MESSAGE_TEMPLATE, rule_type: rule_type, key: key))
      end
    end

    class DuplicateStringKeyError < DuplicateKeyError
      MESSAGE_TEMPLATE = '%<rule_type>s rule with key %<key>s has already been defined. Please remove one of the two.'

      def initialize(rule_type, key)
        super(format(MESSAGE_TEMPLATE, { rule_type: rule_type, key: key }))
      end
    end

    class StringOverwritingSymbolError < DuplicateKeyError
      MESSAGE_TEMPLATE = 'Trying to add %<rule_type>s rule String key %<key>s while a Symbol with the same name already exists. Please remove one of the two.'

      def initialize(rule_type, key)
        super(format(MESSAGE_TEMPLATE, { rule_type: rule_type, key: key }))
      end
    end

    class SymbolOverwritingStringError < DuplicateKeyError
      MESSAGE_TEMPLATE = 'Trying to add %<rule_type>s rule with Symbol key :%<key>s while a String key with the same name already exists. Please remove one of the two.'

      def initialize(rule_type, key)
        super(format(MESSAGE_TEMPLATE, { rule_type: rule_type, key: key }))
      end
    end

    # Raised when it did not expect more data, but there was more left
    class StrictValidationError < ValidationError; end

    # Raised when it expected not to be empty, but it was
    class EmptyOutputError < ValidationError; end

    # Raised when a value did not have the expected type
    class OutputTypeMismatch < ValidationError; end

    # Raised when it expected more data but there wasn't any left
    class ExhaustedOutputError < ValidationError; end

    # Raised when trying to override a non default rule scheme in the Rules Hash's default object method
    class OverwritingUnspecifiedKeyExpectionsError < ArgumentError
      NOT_STRICT_TO_NOT_STRICT_CASE = 'NOT_STRICT_TO_NOT_STRICT'
      NOT_STRICT_TO_ANY_CASE = 'NOT_STRICT_TO_ANY'
      ANY_TO_NOT_STRICT_CASE = 'ANY_TO_NOT_STRICT'
      ANY_TO_ANY_CASE = 'ANY_TO_ANY'
      attr_reader :duplicate_case
      def initialize(msg, dup_case)
        @duplicate_case = dup_case
        super(msg)
      end
    end
  end
end
