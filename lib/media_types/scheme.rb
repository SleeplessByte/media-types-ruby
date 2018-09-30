# frozen_string_literal: true

require 'media_types/scheme/allow_nil'
require 'media_types/scheme/attribute'
require 'media_types/scheme/links'
require 'media_types/scheme/missing_validation'
require 'media_types/scheme/not_strict'

module MediaTypes
  class ValidationError < ArgumentError
  end

  class ExhaustedOutputError < ValidationError
  end

  class StrictValidationError < ValidationError
  end

  class EmptyOutputError < ValidationError
  end

  ##
  # Media Type Schemes can validate content to a media type, by itself.
  #
  class Scheme
    def initialize(allow_empty: false, force_single: false)
      self.validations = {}
      self.allow_empty = allow_empty
      self.force_single = force_single

      validations.default = MissingValidation.new
    end

    ##
    # Checks if the +output+ is valid
    #
    # @param [#each] output
    # @param [Hash] opts
    # @option exhaustive [Boolean] opts
    # @option strict [Boolean] opts
    #
    # @return [Boolean] true if valid, false otherwise
    #
    def valid?(output, **opts)
      validate(output, **opts)
    rescue ExhaustedOutputError
      !opts.fetch(:exhaustive) { true }
    rescue ValidationError
      false
    end

    class ValidationOptions
      attr_accessor :exhaustive, :strict, :backtrace

      def initialize(exhaustive: true, strict: true, backtrace: [])
        self.exhaustive = exhaustive
        self.strict = strict
        self.backtrace = backtrace
      end

      def with_backtrace(backtrace)
        ValidationOptions.new(exhaustive: exhaustive, strict: strict, backtrace: backtrace)
      end

      def trace(*traces)
        with_backtrace(backtrace.dup.concat(traces))
      end

      def exhaustive!
        ValidationOptions.new(exhaustive: true, strict: strict, backtrace: backtrace)
      end
    end

    ##
    # Validates the +output+ and raises on certain validation errors
    #
    # @param [#each] output output to validate
    # @option opts [Boolean] exhaustive if true, the entire schema needs to be consumed
    # @option opts [Boolean] strict if true, no extra keys may be present in +output+
    # @option opts[Array<String>] backtrace the current backtrace for error messages
    #
    # @raise ExhaustedOutputError
    # @raise StrictValidationError
    # @raise EmptyOutputError
    # @raise ValidationError
    #
    # @return [TrueClass]
    #
    def validate(output, options = nil, **opts)
      options ||= ValidationOptions.new(**opts)

      catch(:end) do
        validate!(output, options, context: nil)
      end
    end

    def validate!(output, call_options, **_opts)
      empty_guard!(output, call_options)

      exhaustive_guard!(validations.keys, call_options) do |mark|
        all?(output, call_options) do |key, value, options:, context:|
          mark.call(key)

          validations[key].validate!(
            value,
            options.trace(key),
            context: context
          )
        end
      end
    end

    ##
    # Adds an attribute to the schema
    #
    # @param key [Symbol] the attribute name
    # @param type [Class, #===] The type of the value, can be anything that responds to #===
    # @param opts [Hash] options
    #
    # @example Add an attribute named foo, expecting a string
    #
    #   class MyMedia < Base
    #     current_schema do
    #       attribute :foo, String
    #     end
    #   end
    #
    def attribute(key, type = String, **opts, &block)
      if block_given?
        return collection(key, force_single: true, **opts, &block)
      end

      if type.is_a?(Scheme)
        return validations[key] = type
      end

      validations[key] = Attribute.new(type, **opts, &block)
    end

    ##
    # Allow for any key.
    #   The +block+ defines the Schema for each value.
    #
    # @param [Boolean] allow_empty if true, empty (no key/value present) is allowed
    #
    def any(scheme = nil, force_single: false, allow_empty: false, &block)
      unless block_given?
        return validations.default = scheme
      end

      scheme = Scheme.new(allow_empty: allow_empty, force_single: force_single)
      scheme.instance_exec(&block)

      validations.default = scheme
    end

    ##
    # Allow for extra keys in the schema/collection
    #   even when passing strict: true to #validate!
    #
    def not_strict
      validations.default = NotStrict.new
    end

    ##
    # Expect a collection such as an array or hash.
    #   The +block+ defines the Schema for each item in that collection.
    #
    # @param [Symbol] key
    # @param [Boolean] allow_empty, if true accepts 0 items in an array / hash
    #
    def collection(key, scheme = nil, allow_empty: false, force_single: false, &block)
      unless block_given?
        return validations.default = scheme
      end

      scheme = Scheme.new(allow_empty: allow_empty, force_single: force_single)
      scheme.instance_exec(&block)

      validations[key] = scheme
    end

    ##
    # Expect a link
    #
    def link(*args, **opts, &block)
      validations.fetch(:_links) do
        Links.new.tap do |links|
          validations[:_links] = links
        end
      end.link(*args, **opts, &block)
    end

    private

    attr_accessor :validations, :allow_empty, :force_single

    def empty_guard!(output, options)
      return unless output.nil? || output.empty?
      throw(:end, true) if allow_empty
      raise_empty!(backtrace: options.backtrace)
    end

    class EnumerationContext
      def initialize(validations:)
        self.validations = validations
      end

      def enumerate(val)
        self.key = val
        self
      end

      attr_accessor :validations, :key
    end

    def all?(enumerable, options, &block)
      context = EnumerationContext.new(validations: validations)

      if enumerable.is_a?(Hash) || enumerable.respond_to?(:key)
        return enumerable.all? do |key, value|
          yield key, value, options: options, context: context.enumerate(key)
        end
      end

      enumerable.each_with_index.all? do |array_like_element, i|
        all?(array_like_element, options.trace(i), &block)
      end
    end

    def raise_empty!(backtrace:)
      raise EmptyOutputError, format('Expected output, got empty at %<backtrace>s', backtrace: backtrace.join('->'))
    end

    def raise_exhausted!(backtrace:, missing_keys:)
      raise ExhaustedOutputError, format(
        'Missing keys in output: %<missing_keys>s at [%<backtrace>s]',
        missing_keys: missing_keys,
        backtrace: backtrace.join('->')
      )
    end

    def exhaustive_guard!(keys, options)
      unless options.exhaustive
        return yield(->(_) {})
      end

      exhaustive_keys = keys.dup
      result = yield ->(key) { exhaustive_keys.delete(key) }
      return result if exhaustive_keys.empty?

      raise_exhausted!(missing_keys: exhaustive_keys, backtrace: options.backtrace)
    end
  end
end
