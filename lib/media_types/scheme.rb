# frozen_string_literal: true

require 'media_types/scheme/validation_options'
require 'media_types/scheme/enumeration_context'
require 'media_types/scheme/errors'
require 'media_types/scheme/rules'

require 'media_types/scheme/allow_nil'
require 'media_types/scheme/any_of'
require 'media_types/scheme/attribute'
require 'media_types/scheme/enumeration_of_type'
require 'media_types/scheme/links'
require 'media_types/scheme/missing_validation'
require 'media_types/scheme/not_strict'

require 'media_types/scheme/output_empty_guard'
require 'media_types/scheme/output_type_guard'
require 'media_types/scheme/rules_exhausted_guard'

require 'json'

module MediaTypes
  class AssertionError < StandardError
  end

  class MediaTypeValidationError < StandardError
    def initialize(json, caller)
      @message = "#{json} was expected to fail validations  \n#{caller.path + ':' + caller.lineno.to_s}"
    end

    attr_reader :message
  end

  class FixtureData
    def initialize(caller, fixture, expect_to_pass)
      @caller = caller
      @fixture = fixture
      @expect_to_pass = expect_to_pass
    end
    attr_accessor :caller, :fixture, :expect_to_pass
  end

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

    ##
    # Creates a new scheme
    #
    # @param [TrueClass, FalseClass] allow_empty if true allows to be empty, if false raises EmptyOutputError if empty
    # @param [NilClass, Class] expected_type forces the type to be this type, if given
    #
    # @see MissingValidation
    #
    def initialize(allow_empty: false, expected_type: ::Object, &block)
      self.rules = Rules.new(allow_empty: allow_empty, expected_type: expected_type)
      self.type_attributes = {}

      @fixtures = []
      @asserted_sane = false

      instance_exec(&block) if block_given?
    end

    attr_accessor :type_attributes, :fixtures, :asserted_sane
    attr_reader :rules

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
      options.context = output

      catch(:end) do
        validate!(output, options, context: nil)
      end
    end

    #
    # @private
    #
    def validate!(output, call_options, **_opts)
      OutputTypeGuard.call(output, call_options, rules: rules)
      OutputEmptyGuard.call(output, call_options, rules: rules)
      RulesExhaustedGuard.call(output, call_options, rules: rules)
    end

    ##
    # Adds an attribute to the schema
    #   If a +block+ is given, uses that to test against instead of +type+
    #
    # @param key [Symbol] the attribute name
    # @param opts [Hash] options to pass to Scheme or Attribute
    # @param type [Class, #===, Scheme] The type of the value, can be anything that responds to #===,
    #   or scheme to use if no +&block+ is given. Defaults to Object without a +&block+ and to Hash with a +&block+.
    #   or scheme to use if no +&block+ is given. Defaults to Object without a +&block+ and to Hash with a +&block+.
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
    def attribute(key, type = ::Object, optional: false, **opts, &block)
      raise KeyTypeError, "Unexpected key type #{key.class.name}, please use either a symbol or string." unless key.is_a?(String) || key.is_a?(Symbol)
      raise DuplicateKeyError, "An attribute with key #{key} has already been defined. Please remove one of the two." if rules.has_key?(key)
      raise DuplicateKeyError, "A string attribute with the same string representation as the symbol :#{key} already exists. Please remove one of the two." if key.is_a?(Symbol) && rules.has_key?(key.to_s)
      raise DuplicateKeyError, "A symbol attribute with the same string representation as the string '#{key}' already exists. Please remove one of the two." if key.is_a?(String) && rules.has_key?(key.to_sym)

      if block_given?
        return collection(key, expected_type: ::Hash, optional: optional, **opts, &block)
      end

      if type.is_a?(Scheme)
        return rules.add(key, type, optional: optional)
      end

      rules.add(key, Attribute.new(type, **opts, &block), optional: optional)
    end

    ##
    # Allow for any key.
    #   The +&block+ defines the Schema for each value.
    #
    # @param [Scheme, NilClass] scheme scheme to use if no +&block+ is given
    # @param [TrueClass, FalseClass] allow_empty if true, empty (no key/value present) is allowed
    # @param [Class] expected_type forces the validated object to have this type
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
    # @example Any key, but all of them String or Numeric
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       any AnyOf(String, Numeric)
    #     end
    #   end
    #
    #   MyMedia.valid?({ foo: 'my-string', bar: 42 })
    #   # => true
    #
    def any(scheme = nil, expected_type: ::Hash, allow_empty: false, &block)
      unless block_given?
        if scheme.is_a?(Scheme)
          return rules.default = scheme
        end

        return rules.default = Attribute.new(scheme)
      end

      rules.default = Scheme.new(allow_empty: allow_empty, expected_type: expected_type, &block)
    end

    ##
    # Merges a +scheme+ into this scheme without changing the incoming +scheme+
    #
    # @param [Scheme] scheme the scheme to merge into this
    #
    def merge(scheme, &block)
      self.rules = rules.merge(scheme.send(:rules))
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
      rules.default = NotStrict.new
    end

    ##
    # Expect a collection such as an array or hash.
    #   The +block+ defines the Schema for each item in that collection.
    #
    # @param [Symbol] key key of the collection (same as #attribute)
    # @param [NilClass, Scheme, Class] scheme scheme to use if no +&block+ is given, or type of each item in collection
    # @param [TrueClass, FalseClass] allow_empty if true accepts 0 items in an enumerable
    # @param [Class] expected_type forces the value of this collection to be this type, defaults to Array.
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
    def collection(key, scheme = nil, allow_empty: false, expected_type: ::Array, optional: false, &block)
      unless block_given?
        return rules.add(
          key,
          EnumerationOfType.new(
            scheme,
            enumeration_type: expected_type,
            allow_empty: allow_empty
          ),
          optional: optional
        )
      end

      rules.add(key, Scheme.new(allow_empty: allow_empty, expected_type: expected_type, &block), optional: optional)
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
      rules.fetch(:_links) do
        Links.new.tap do |links|
          rules.add(:_links, links)
        end
      end.link(*args, **opts, &block)
    end

    ##
    # Mark object as a valid empty object
    #
    # @example Empty object
    #
    #   class MyMedia
    #     include MediaTypes::Dsl
    #
    #     validations do
    #       empty
    #     end
    #   end
    def empty
    end

    def inspect(indentation = 0)
      tabs = '  ' * indentation
      [
        "#{tabs}[Scheme]",
        rules.inspect(indentation + 1),
        "#{tabs}[/Scheme]"
      ].join("\n")
    end

    def assert_pass(fixture)
      @fixtures << FixtureData.new(caller_locations[1], fixture, true)
    end

    def assert_fail(fixture)
      @fixtures << FixtureData.new(caller_locations[1], fixture, false)
    end

    def execute_assertions
      errors ||=
        @fixtures.each_with_object([]) do |fixture_data, error_array|
          json = JSON.parse(fixture_data.fixture, { symbolize_names: true })
          output = fixture_data.expect_to_pass ? process_assert_pass(json, fixture_data.caller) : process_assert_fail(json, fixture_data.caller)
          error_array << output unless output.nil?
        end
      raise AssertionError, errors unless errors.empty?

      @asserted_sane = true
    end

    def process_assert_fail(json, caller)
      begin
        validate(json)
      rescue MediaTypes::Scheme::ValidationError
        expectation_met = true
      end
      MediaTypeValidationError.new(json, caller) unless expectation_met
    end

    def process_assert_pass(json, caller)
      error = nil
      begin
        validate(json)
      rescue StandardError => e
        error = e.message + "\n#{caller.path + ':' + caller.lineno.to_s}"
      end
      error
    end

    private

    attr_writer :rules
  end
end
