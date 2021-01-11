# frozen_string_literal: true

require 'media_types/scheme/errors'
require 'media_types/scheme/output_iterator_with_predicate'

module MediaTypes
  class Scheme
    class RulesExhaustedGuard

      EMPTY_MARK = ->(_) {}

      class << self
        def call(*args, **opts, &block)
          new(*args, **opts).call(&block)
        end
      end

      def initialize(output, options, rules:)
        self.rules = rules
        self.output = output
        self.options = options
      end

      def call
        unless options.exhaustive
          return iterate(EMPTY_MARK)
        end

        required_rules = rules.required
        # noinspection RubyScope
        result = iterate(->(key) { required_rules.remove(key) })
        return result if required_rules.empty?

        raise_exhausted!(missing_keys: required_rules.keys, backtrace: options.backtrace, found: output)
      end

      def iterate(mark)
        OutputIteratorWithPredicate.call(output, options, rules: rules) do |key, value, options:, context:|
          raise ValidationError,
              format(
                'Expected key as %<type>s, got %<actual>s at [%<backtrace>s]',
                type: options.expected_key_type,
                actual: key.class,
                backtrace: options.trace(key).backtrace.join('->')
              ) unless key.class == options.expected_key_type || rules.get(key).class == NotStrict

          mark.call(key)

          rules.get(key).validate!(
            value,
            options.trace(key),
            context: context
          )
        end
      end

      private

      attr_accessor :rules, :options, :output

      def raise_exhausted!(missing_keys:, backtrace:, found:)
        raise ExhaustedOutputError, format(
          'Missing keys in output: %<missing_keys>s at [%<backtrace>s]. I did find: %<found>s',
          missing_keys: missing_keys,
          backtrace: backtrace.join('->'),
          found: (found.is_a? Hash) ? found.keys : found.class.name,
        )
      end
    end
  end
end
