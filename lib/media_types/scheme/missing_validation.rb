# frozen_string_literal: true

module MediaTypes
  class Scheme
    class MissingValidation

      def validate!(_output, options, context:, **_opts)
        # Check that no unknown keys are present
        return true unless options.strict
        raise_strict!(key: context.key, strict_keys: context.validations, backtrace: options.backtrace)
      end

      def raise_strict!(key:, backtrace:, strict_keys:)
        raise StrictValidationError, format(
          'Unknown key %<key>s in output at [%<backtrace>s]. Expected one of: %<strict_keys>s',
          key: key.inspect,
          backtrace: backtrace.join('->'),
          strict_keys: strict_keys
        )
      end

    end
  end
end
