# frozen_string_literal: true

require 'media_types/scheme/errors'

module MediaTypes
  class Scheme
    class MissingValidation

      def validate!(_output, options, context:, **_opts)
        # Check that no unknown keys are present
        return true unless options.strict
        raise_strict!(key: context.key, strict_keys: context.rules, backtrace: options.backtrace, found: options.scoped_output)
      end

      def raise_strict!(key:, backtrace:, strict_keys:, found:)
        raise StrictValidationError, format(
          "Unknown key %<key>s in data.\n" \
          "\tFound at: %<backtrace>s\n" \
          "\tExpected:\n\n" \
          "%<strict_keys>s\n\n" \
          "\tBut I Found:\n\n" \
          '%<found>s',
          key: key.inspect,
          backtrace: backtrace.join('->'),
          strict_keys: keys_to_str(strict_keys.keys),
          found: (found.respond_to? :keys) ? keys_to_str(found.keys) : found.class.name
        )
      end

      def inspect
        '((raise when strict))'
      end

      def keys_to_str(keys)
        converted = keys.map { |k| k.is_a?(Symbol) ? ":#{k}" : "'#{k}'" }
        "[#{converted.join ', '}]"
      end

    end
  end
end
