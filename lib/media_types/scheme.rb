# frozen_string_literal: true

require 'media_types/scheme/validation_options'
require 'media_types/scheme/enumeration_context'

require 'media_types/scheme/allow_nil'
require 'media_types/scheme/any_of'
require 'media_types/scheme/attribute'
require 'media_types/scheme/enumeration_of_type'
require 'media_types/scheme/links'
require 'media_types/scheme/missing_validation'
require 'media_types/scheme/not_strict'

module MediaTypes
  ##
  # Media Type Schemes can validate content to a media type, by itself. Used by the `validations` dsl.
  #
  # @see MediaTypes::Dsl
  #
  # @example A scheme to test against
  #
  #   class MyMedia
  #     include MediaTypes::Dsl
  #
  #     validations do
  #       attribute :foo do
  #         collection :bar, String
  #       end
  #       attribute :number, Numeric
  #     end
  #   end
  #
  #   MyMedia.valid?({ foo: { bar: ['test'] }, number: 42 })
  #   #=> true
  #
  class Scheme

    # Base class for all validations errors
    class ValidationError < ArgumentError; end

    # Raised when it expected more data but there wasn't any left
    class ExhaustedOutputError < ValidationError; end

    # Raised when it did not expect more data, but there was more left
    class StrictValidationError < ValidationError; end

    # Raised when it expected not to be empty, but it was
    class EmptyOutputError < ValidationError; end

    # Raised when a value did not have the expected collection type
    class CollectionTypeError < ValidationError; end

    ##
    # Creates a new scheme
    #
    # @param [TrueClass, FalseClass] allow_empty if true allows to be empty, if false raises EmptyOutputError if empty
    # @param [NilClass, Class] force forces the type to be this type, if given
    #
    # @see MissingValidation
    #
    def initialize(allow_empty: false, force: nil)
      self.validations = {}
      self.allow_empty = allow_empty
      self.force = force

      validations.default = MissingValidation.new
    end

    ##
    # Checks if the +output+ is valid
    #
    # @param [#each] output the output to test against
    # @param [Hash] opts the options as defined below
    # @option exhaustive [TrueClass, FalseClass] opts if true, raises when it expected more data but there wasn't any
    # @option strict [TrueClass, FalseClass] opts if true, raised when it did not expect more data, but there was more
    #
    # @return [TrueClass, FalseClass] true if valid, false otherwise
    #
    def valid?(output, **opts)
      validate(output, **opts)
    rescue ExhaustedOutputError
      !opts.fetch(:exhaustive) { true }
    rescue ValidationError
      false
    end

    ##
    # Validates the +output+ and raises on certain validation errors
    #
    # @param [#each] output output to validate
    # @option opts [TrueClass, FalseClass] exhaustive if true, the entire schema needs to be consumed
    # @option opts [TrueClass, FalseClass] strict if true, no extra keys may be present in +output+
    # @option opts[Array<String>] backtrace the current backtrace for error messages
    #
    # @raise ExhaustedOutputError
    # @raise StrictValidationError
    # @raise EmptyOutputError
    # @raise CollectionTypeError
    # @raise ValidationError
    #
    # @see #validate!
    #
    # @return [TrueClass]
    #
    def validate(output, options = nil, **opts)
      options ||= ValidationOptions.new(**opts)

      catch(:end) do
        validate!(output, options, context: nil)
      end
    end

    #
    # @private
    #
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
    #   If a +block+ is given, uses that to test against instead of +type+
    #
    # @param key [Symbol] the attribute name
    # @param opts [Hash] options to pass to Scheme or Attribute
    # @param type [Class, #===, Scheme] The type of the value, can be anything that responds to #===,
    #   or scheme to use if no +&block+ is given. Defaults to String without a +&block+ and to Hash with a +&block+.
    #
    # @see Scheme::Attribute
    # @see Scheme
    #
    # @example Add an attribute named foo, expecting a string
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       attribute :foo, String
    #     end
    #   end
    #
    #   MyMedia.valid?({ foo: 'my-string' })
    #   # => true
    #
    # @example Add an attribute named foo, expecting nested scheme
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       attribute :foo do
    #         attribute :bar, String
    #       end
    #     end
    #   end
    #
    #   MyMedia.valid?({ foo: { bar: 'my-string' }})
    #   # => true
    #
    def attribute(key, type = String, **opts, &block)
      if block_given?
        return collection(key, force: ::Hash, **opts, &block)
      end

      if type.is_a?(Scheme)
        return validations[String(key)] = type
      end

      validations[String(key)] = Attribute.new(type, **opts, &block)
    end

    ##
    # Allow for any key.
    #   The +&block+ defines the Schema for each value.
    #
    # @param [Scheme, NilClass] scheme scheme to use if no +&block+ is given
    # @param [TrueClass, FalseClass] allow_empty if true, empty (no key/value present) is allowed
    # @param [Class] force forces the validated object to have this type
    #
    # @see Scheme
    #
    # @example Add a collection named foo, expecting any key with a defined value
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       collection :foo do
    #         any do
    #           attribute :bar, String
    #         end
    #       end
    #     end
    #   end
    #
    #   MyMedia.valid?({ foo: [{ anything: { bar: 'my-string' }, other_thing: { bar: 'other-string' } }] })
    #   # => true
    #
    def any(scheme = nil, force: ::Hash, allow_empty: false, &block)
      unless block_given?
        return validations.default = scheme
      end

      scheme = Scheme.new(allow_empty: allow_empty, force: force)
      scheme.instance_exec(&block)

      validations.default = scheme
    end

    ##
    # Merges a +scheme+ into this scheme without changing the incoming +scheme+
    #
    # @param [Scheme] scheme the scheme to merge into this
    #
    def merge(scheme, &block)
      self.validations = validations.merge(scheme.send(:validations).dup)
      instance_exec(&block) if block_given?
    end

    ##
    # Allow for extra keys in the schema/collection even when passing strict: true to #validate!
    #
    # @see Scheme::NotStrict
    #
    # @example Allow for extra keys in collection
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       collection :foo do
    #         attribute :required, String
    #         not_strict
    #       end
    #     end
    #   end
    #
    #   MyMedia.valid?({ foo: [{ required: 'test', bar: 42 }] })
    #   # => true
    #
    def not_strict
      validations.default = NotStrict.new
    end

    ##
    # Expect a collection such as an array or hash.
    #   The +block+ defines the Schema for each item in that collection.
    #
    # @param [Symbol] key key of the collection (same as #attribute)
    # @param [NilClass, Scheme, Class] scheme scheme to use if no +&block+ is given, or type of each item in collection
    # @param [TrueClass, FalseClass] allow_empty if true accepts 0 items in an enumerable
    # @param [Class] force forces the value of this collection to be this type, defaults to Array.
    #
    # @see Scheme
    #
    # @example Collection with an array of string
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       collection :foo, String
    #     end
    #   end
    #
    #   MyMedia.valid?({ collection: ['foo', 'bar'] })
    #   # => true
    #
    # @example Collection with defined scheme
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       collection :foo do
    #         attribute :required, String
    #         attribute :number, Numeric
    #       end
    #     end
    #   end
    #
    #   MyMedia.valid?({ foo: [{ required: 'test', number: 42 }, { required: 'other', number: 0 }] })
    #   # => true
    #
    def collection(key, scheme = nil, allow_empty: false, force: Array, &block)
      unless block_given?
        if scheme.is_a?(Scheme)
          return validations[String(key)] = scheme
        end

        return validations[String(key)] = EnumerationOfType.new(
          scheme,
          enumeration_type: force,
          allow_empty: allow_empty
        )
      end

      scheme = Scheme.new(allow_empty: allow_empty, force: force)
      scheme.instance_exec(&block)

      validations[String(key)] = scheme
    end

    ##
    # Expect a link
    #
    # @see Scheme::Links
    #
    # @example Links as defined in HAL, JSON-Links and other specs
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       link :_self
    #       link :image
    #     end
    #   end
    #
    #   MyMedia.valid?({ _links: { self: { href: 'https://example.org/s' }, image: { href: 'https://image.org/i' }} })
    #   # => true
    #
    # @example Link with extra attributes
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       link :image do
    #         attribute :templated, TrueClass
    #       end
    #     end
    #   end
    #
    #   MyMedia.valid?({ _links: { image: { href: 'https://image.org/{md5}', templated: true }} })
    #   # => true
    #
    def link(*args, **opts, &block)
      validations.fetch(:_links) do
        Links.new.tap do |links|
          validations[:_links] = links
        end
      end.link(*args, **opts, &block)
    end

    private

    attr_accessor :validations, :allow_empty, :force

    ##
    # Checks if the output is nil or empty
    #
    # @private
    #
    def empty_guard!(output, options)
      return unless MediaTypes::Object.new(output).empty?
      throw(:end, true) if allow_empty
      raise_empty!(backtrace: options.backtrace)
    end

    ##
    # Mimics Enumerable#all? with mandatory +&block+
    #
    def all?(enumerable, options, &block)
      context = EnumerationContext.new(validations: validations)

      if force && !(force === enumerable) # rubocop:disable Style/CaseEquality
        raise_forced_type_error!(type: enumerable.class, backtrace: options.backtrace)
      end

      if enumerable.is_a?(Hash) || enumerable.respond_to?(:key)
        return enumerable.all? do |key, value|
          yield String(key), value, options: options, context: context.enumerate(key)
        end
      end

      without_forcing_type do
        enumerable.each_with_index.all? do |array_like_element, i|
          all?(array_like_element, options.trace(i), &block)
        end
      end
    end

    def raise_forced_type_error!(type:, backtrace:)
      raise CollectionTypeError, format(
        'Expected a %<expected>s, got a %<actual>s at %<backtrace>s',
        expected: force,
        actual: type,
        backtrace: backtrace.join('->')
      )
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

      exhaustive_keys = keys.dup.map(&:to_s)
      # noinspection RubyScope
      result = yield ->(key) { exhaustive_keys.delete(String(key)) }
      return result if exhaustive_keys.empty?

      raise_exhausted!(missing_keys: exhaustive_keys, backtrace: options.backtrace)
    end

    def without_forcing_type
      before_force = force
      self.force = nil
      result = yield
      self.force = before_force
      result
    end
  end
end
